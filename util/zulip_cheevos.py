#!/usr/bin/env python3

# TODO:
# - topic 
# - write to tsv files that can be uploaded to Canvas with lms-toolkit

import csv
import zulip
from typing import Any
from datetime import datetime, timezone
from datetimerange import DateTimeRange

# Get the latest message sent by `student` to `channel_name`, if it exists.
# Returns a list with either 0 or 1 elements.
def get_latest_message(student, channel_name, topic_name=None):
    request: dict[str, Any] = {
        "anchor": "newest",
        "num_before": 1,
        "num_after": 0,
        "narrow": [
            {"operator": "sender", "operand": student['email']},
            {"operator": "channel", "operand": channel_name},
        ],
    }
    
    if topic_name:
        request["narrow"].append({"operator": "topic", "operand": topic_name})
        
    result = client.get_messages(request)
    return result['messages']

# Returns `True` if `message` was posted during `date_time_range`, and
# `False` otherwise.
def in_range(message, date_time_range):
    message_time = datetime.fromtimestamp(message['timestamp']).replace(tzinfo=timezone.utc)
    return message_time in date_time_range

if __name__ == '__main__':
    # Set up lists for all Zulip-related cheevos

    # First Post: Post in the Zulip #assignments, #lectures, or
    # #general channels sometime during the first 5 weeks of the
    # quarter.
    first_post = []

    # Pawtrait Mode: Post in the Zulip #social>pets topic sometime
    # during the first 5 weeks of the quarter.
    pawtrait_mode = []

    # Attention Span: Post in the Zulip #assignments, #lectures, or
    # #general channels sometime during weeks 6-10 of the quarter.
    attention_span = []

    # Define DateTimeRanges used for various cheevos.
    wk_1_5 = DateTimeRange("2026-03-29T00:00:00-7:00",
                           "2026-05-03T23:59:59-7:00")
    wk_6_10 = DateTimeRange("2026-05-04T00:00:00-7:00",
                            "2026-06-09T23:59:59-7:00")

    # Set up the client object.
    client = zulip.Client(config_file="~/.zuliprc_ucsc-cse114a")

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

    # log "First Post" and "Attention Span" cheevos
    # TODO: remove "course staff"
    channel_names = ["assignments", "general", "lectures", "course staff"]
    for student in students:
        sent_messages = []
        for name in channel_names:
            latest_message = get_latest_message(student, name)
            if latest_message != []:
                sent_messages.append(latest_message[0])
                
        print(len(sent_messages), "posts by", student['delivery_email'])
                
        in_range_1_5 = [ in_range(message, wk_1_5) for message in sent_messages ]
        if any(in_range_1_5):
            first_post.append(student['delivery_email'])

        in_range_6_10 = [ in_range(message, wk_6_10) for message in sent_messages ]
        if any(in_range_6_10):
            attention_span.append(student['delivery_email'])

    # log "Pawtrait Mode" cheevo
    for student in students:
        latest_message = get_latest_message(student, "social", "pets")
        if latest_message != []:
            pawtrait_mode.append(student['delivery_email'])

    # TODO: produce tsv output for lms-toolkit
    print(first_post)
    print(attention_span)
    print(pawtrait_mode)
                                 
                            

            

        
        
        

