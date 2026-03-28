#!/usr/bin/env python3

# TODO:
# - post length enforcement?
# - write to tsv files that can be uploaded to Canvas with lms-toolkit

import zulip
from typing import Any
from datetime import datetime, timezone
from datetimerange import DateTimeRange

# Define DateTimeRanges for the first five weeks and second five weeks of the course.
before_course = DateTimeRange("2026-03-25T00:00:00-7:00", "2026-03-29T23:59:59-7:00")
weeks_1_5 = DateTimeRange("2026-03-30T00:00:00-7:00", "2026-05-03T23:59:59-7:00")
weeks_6_10 = DateTimeRange("2026-05-04T00:00:00-7:00", "2026-06-09T23:59:59-7:00")

# Path to zuliprc file.
client = zulip.Client(config_file="~/.zuliprc_ucsc-cse114a")

# Returns True if `student` posted in `channel_name` during `date_time_range`.
def posted_in(student, channel_name, date_time_range):
    # Get the latest 1000 messages sent by `student` to `channel_name`.
    request: dict[str, Any] = {
        "anchor": "newest",
        "num_before": 1000,
        "num_after": 0,
        "narrow": [
            {"operator": "sender", "operand": student['email']},
            {"operator": "channel", "operand": channel_name},
        ],
    }
    result = client.get_messages(request)

    message_exists_in_range = False
    for message in result['messages']:
        message_time = datetime.fromtimestamp(message['timestamp']).replace(tzinfo=timezone.utc)
        if message_time in date_time_range:
            message_exists_in_range = True
            break
    return message_exists_in_range
        
# Get all users in the organization.
result = client.get_members()

# Get a list of student users.
students = []
if result['result'] == 'success':
    for user in result['members']:
        # Exclude deactivated users and course staff.
        # The 'role' property is 400 for organization "Member"s,
        # as opposed to owners/administrators/moderators/guests.
        # https://chat.zulip.org/api/roles-and-permissions
        if user['is_active'] and user['role'] == 300: # TODO: change to 400
            students.append(user)

# See where the student has posted.
for student in students:
    for channel_name in ["assignments", "general", "lectures", "course staff"]:
        if posted_in(student, channel_name, weeks_1_5):
            print(student['delivery_email'], "posted in", channel_name, "during weeks 1-5")
        if posted_in(student, channel_name, weeks_6_10):
            print(student['delivery_email'], "posted in", channel_name, "during weeks 6-10")
        if posted_in(student, channel_name, before_course):
            print(student['delivery_email'], "posted in", channel_name, "before the course started")
