"""
`my_script vpn_menu` : rofi menu to start a vpn or ssh connection in a kitty terminal (i3 $mod+w).

Each folder of ~/.config/openvpn/client/ is an entry, described by its .env file (NAME, TYPE...).
3 TYPE are supported (see the README for the .env content) :
- openvpn : `sudo openvpn` with the client.ovpn and pass.txt files of the folder,
- openconnect : `sudo openconnect` (anyconnect protocol), with LOGIN / GROUP / SERVER / PASSWORD,
- sshpass : ssh with a password, with USER / SERVER_NAME / SERVER_PORT / PASSWORD.
"""

import os
import shlex
import subprocess

VPN_CONFIG_FOLDER = os.path.expanduser("~/.config/openvpn/")

CLIENT_FOLDER = os.path.join(VPN_CONFIG_FOLDER, "client")


def main():
    client_folders = [os.path.join(CLIENT_FOLDER, d) for d in os.listdir(CLIENT_FOLDER) if os.path.isdir(os.path.join(CLIENT_FOLDER, d))]
    # (name, command, env) : passwords are given threw env variables, so they don't appear in the process list
    options = []

    for client_folder in client_folders:
        # get the value of the .env file
        env_file = os.path.join(client_folder, ".env")
        env_values = {}
        if os.path.exists(env_file):
            with open(env_file) as f:
                env_content = f.read()
                for line in env_content.split("\n"):
                    if line and not line.startswith("#"):
                        key, value = line.split("=", 1)
                        env_values[key] = value.strip('"')

            if "NAME" in env_values.keys() and "TYPE" in env_values.keys():
                # 3 type of VPN: openvpn, openconnect, sshpass
                print(f"Found {env_values['NAME']} ({env_values['TYPE']})")
                # quote the values to avoid shell injection
                q = {key: shlex.quote(value) for key, value in env_values.items()}
                if env_values["TYPE"] == "openvpn":
                    options.append((env_values['NAME'], f"sudo openvpn --cd {shlex.quote(VPN_CONFIG_FOLDER)} --config {shlex.quote(os.path.join(client_folder, 'client.ovpn'))} --auth-nocache --auth-user-pass {shlex.quote(os.path.join(client_folder, 'pass.txt'))}", {}))
                elif env_values["TYPE"] == "openconnect":
                    options.append((env_values['NAME'], f'printf "%s\\n" "$VPN_PASSWORD" | sudo openconnect --protocol anyconnect --passwd-on-stdin --user {q["LOGIN"]} --authgroup {q["GROUP"]} --server {q["SERVER"]}', {"VPN_PASSWORD": env_values["PASSWORD"]}))
                elif env_values["TYPE"] == "sshpass":
                    options.append((env_values['NAME'], f'export TERM=xterm-256color; sshpass -e ssh -t -p {q["SERVER_PORT"]} {q["USER"]}@{q["SERVER_NAME"]}', {"SSHPASS": env_values["PASSWORD"]}))
                else:
                    print(f"Error: {client_folder} has an unknown TYPE value")

            else:
                print(f"Error: {client_folder} isn't a known VPN client folder")

        else:
            print(f"Error: {client_folder} does not contain a .env file")

    # Display Rofi menu
    # Build the options string for the Rofi menu
    options_string = "\n".join(opt[0] for opt in options)

    choice = subprocess.run([os.environ["MY_SCRIPT"], "rofi", "-dmenu", "-p", "Select a vpn"], input=options_string, text=True, capture_output=True).stdout.strip()

    # Execute the corresponding command
    for option, command, env in options:
        if choice == option:
            if command:  # if command is not empty
                full_command = f'{command}; echo -e "Waiting 100s..."; sleep 100'
                subprocess.Popen(["kitty", "-e", "bash", "-c", full_command], env={**os.environ, **env})
            break


if __name__ == "__main__":
    main()
