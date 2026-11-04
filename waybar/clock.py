"""
The waybar clock (custom/clock module) : the time in the bar ; on hover, the date in English, the date in French
in small under it, then the calendar of the month with today highlighted.
The French names are written here : the French locale isn't installed (and a waybar module has one locale only).
"""

import calendar
import json
from datetime import date, datetime

FRENCH_DAYS = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]
FRENCH_MONTHS = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre",
                 "novembre", "décembre"]

# the colors of the polybar / waybar theme (style.css)
TODAY = "#ff8700"
WEEKDAYS = "#f0b746"


def month_calendar(today: date) -> str:
    """the month like `cal` (Monday first), with pango markup : today in orange bold, the weekdays in yellow"""
    lines = calendar.TextCalendar(firstweekday=0).formatmonth(today.year, today.month).rstrip("\n").split("\n")
    title, weekdays, weeks = lines[0], lines[1], lines[2:]
    marked = []
    for week in weeks:
        # each day is in a 3 characters column ("dd "), so today is replaced at its exact position
        cells = [week[i:i + 3] for i in range(0, len(week), 3)]
        marked.append("".join(
            f"<span color='{TODAY}'><b>{cell}</b></span>" if cell.strip() == str(today.day) else cell
            for cell in cells
        ))
    return "\n".join([f"<b>{title}</b>", f"<span color='{WEEKDAYS}'><b>{weekdays}</b></span>", *marked])


def main() -> None:
    now = datetime.now()
    english = now.strftime("%A %d %B %Y")
    french = f"{FRENCH_DAYS[now.weekday()]} {now.day} {FRENCH_MONTHS[now.month - 1]} {now.year}"
    tooltip = f"<big>{english}</big>\n<small>{french}</small>\n<tt>{month_calendar(now.date())}</tt>"
    print(json.dumps({"text": now.strftime("%H:%M"), "tooltip": tooltip}))


if __name__ == "__main__":
    main()
