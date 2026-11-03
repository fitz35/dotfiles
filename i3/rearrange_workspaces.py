import argparse
import json
import os
import re
import shlex
import subprocess
from typing import Dict, List


DIR = os.path.dirname(os.path.abspath(__file__))

I3_CONFIG = os.path.join(DIR, 'config')


def i3_msg(*args: str) -> list:
    return json.loads(subprocess.run(['i3-msg', *args], capture_output=True, text=True, check=True).stdout)

def parse_workspace_outputs(config: str) -> Dict[str, List[str]]:
    """return a dict with the workspace name as key and the assigned outputs (by priority) as value"""
    variables: Dict[str, str] = {}
    assignments: Dict[str, List[str]] = {}
    for line in config.splitlines():
        line = line.strip()
        set_match = re.match(r'^set\s+(\$\S+)\s+(.+)$', line)
        if set_match:
            variables[set_match.group(1)] = set_match.group(2)
            continue
        if not line.startswith('workspace '):
            continue
        # i3 replaces the variables as text, the longest first ($ws10 before $ws1)
        for name in sorted(variables, key=len, reverse=True):
            line = line.replace(name, variables[name])
        words = shlex.split(line)
        if len(words) >= 4 and words[2] == 'output':
            assignments[words[1]] = words[3:]
    return assignments

def get_argv_parser():
    parser = argparse.ArgumentParser(description='Move the open workspaces to their assigned screen (from the i3 config).')
    parser.add_argument('-n', '--dry-run', action='store_true', help="only print the moves")
    return parser

if __name__ == '__main__':
    parser = get_argv_parser()
    args = parser.parse_args()

    with open(I3_CONFIG) as config_file:
        assignments = parse_workspace_outputs(config_file.read())
    active_outputs = {output['name'] for output in i3_msg('-t', 'get_outputs') if output['active']}
    workspaces = i3_msg('-t', 'get_workspaces')

    commands: List[str] = []
    for workspace in workspaces:
        outputs = [output for output in assignments.get(workspace['name'], []) if output in active_outputs]
        if outputs and workspace['output'] != outputs[0]:
            print(f"{workspace['name']} : {workspace['output']} -> {outputs[0]}")
            commands.append(f'workspace --no-auto-back-and-forth {json.dumps(workspace["name"], ensure_ascii=False)}; '
                            f'move workspace to output {outputs[0]}')

    if args.dry_run or not commands:
        exit(0)

    # restore the visible workspaces, then the focused one (moving a workspace focuses it)
    visible = [workspace['name'] for workspace in workspaces if workspace['visible'] and not workspace['focused']]
    focused = [workspace['name'] for workspace in workspaces if workspace['focused']]
    for name in visible + focused:
        commands.append(f'workspace --no-auto-back-and-forth {json.dumps(name, ensure_ascii=False)}')

    i3_msg('; '.join(commands))
