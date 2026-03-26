#!/usr/bin/env python3

import zulip

# Pass the path to your zuliprc file here.
client = zulip.Client(config_file="~/.zuliprc_ucsc-cse114a")

# Get all users in the realm
result = client.get_members()

staff_emails_spring_2026 = [
     'lkuper@ucsc.edu'       # Instructor: Lindsey
]
    
if result['result'] == 'success':
    for user in result['members']:
        # Don't deactivate staff
        if user['delivery_email'] in staff_emails_spring_2025:
            print("Keeping this user:", user['delivery_email'])
        # Deactivate everyone else
        else:
            if user['is_active']:
                print("User is active: ", user['delivery_email'], user['user_id'])
                print("DEACTIVATING this user:", user['delivery_email'], user['user_id'])
                deactivation_result = client.deactivate_user_by_id(user['user_id'])
                print(deactivation_result)
