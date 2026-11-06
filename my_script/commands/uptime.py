"""
`my_script uptime [-display_entry]` : track how long the computer is on each day (bar uptime module).

Without argument (called every minute by the bar) : save the uptime of this boot in ~/daily_uptime.txt,
one line per boot "YYYY-MM-DD HH:MM:SS -  H:MM" (date of the last update - uptime of the boot),
then print the cumulated uptime of today as HH:MM.
With -display_entry (click on the module) : show today's lines in rofi.

The file is analysed by the my_personnal_script repository (copies are kept in its daily_uptime_save/).
"""

import argparse
import os
import subprocess
from datetime import datetime
from typing import cast

UPTIME_FILE = os.path.expanduser("~/daily_uptime.txt")
DATE_FORMAT = "%Y-%m-%d %H:%M:%S"


def read_lines() -> list[str]:
    if not os.path.exists(UPTIME_FILE):
        return []
    with open(UPTIME_FILE) as file:
        return [line.strip() for line in file if line.strip()]


def parse_line(line: str) -> tuple[datetime, int]:
    """("2026-11-03 14:53:19 -  0:49") → (date of the last update, uptime in minutes)"""
    date, uptime = line.split(" - ")
    hours, minutes = map(int, uptime.split(":"))
    return datetime.strptime(date, DATE_FORMAT), hours * 60 + minutes


def current_uptime_minutes() -> int:
    """from /proc/uptime (the `uptime` command prints "1 day, H:MM" after 24h, which can't be parsed)"""
    with open("/proc/uptime") as file:
        return int(float(file.read().split()[0])) // 60


def record(now: datetime, lines: list[str]) -> list[str]:
    """the lines with the uptime of this boot : its line is updated, or added if the last line is an older boot"""
    minutes = current_uptime_minutes()
    if minutes == 0:  # avoid the 0 min lines
        return lines
    hours, rest = divmod(minutes, 60)
    line = f"{now.strftime(DATE_FORMAT)} - {hours:2}:{rest:02}"
    if lines:
        last_date, _ = parse_line(lines[-1])
        # updated less than "uptime" minutes ago : the same boot
        if (now - last_date).total_seconds() / 60 <= minutes:
            return lines[:-1] + [line]
    return lines + [line]


def main() -> None:
    parser = argparse.ArgumentParser(description="Daily uptime, saved in ~/daily_uptime.txt.")
    _ = parser.add_argument("-display_entry", action="store_true", help="show today's lines in rofi")
    display_entry = cast(bool, parser.parse_args().display_entry)

    now = datetime.now()
    lines = read_lines()
    todays_lines = [line for line in lines if parse_line(line)[0].date() == now.date()]

    if display_entry:
        menu = "\n".join(reversed(todays_lines))  # the most recent first
        _ = subprocess.run([os.environ["MY_SCRIPT"], "rofi", "-dmenu", "-p", "Today's Uptimes"], input=menu, text=True, check=False)
        return

    new_lines = record(now, lines)
    if new_lines != lines:
        with open(UPTIME_FILE, "w") as file:
            _ = file.write("\n".join(new_lines) + "\n")

    today = sum(parse_line(line)[1] for line in new_lines if parse_line(line)[0].date() == now.date())
    hours, minutes = divmod(today, 60)
    print(f"{hours:02}:{minutes:02}")


if __name__ == "__main__":
    main()
