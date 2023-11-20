import json
import os
import pymysql
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def serialize_date(date):
    """Convert a date object to a string."""
    if date:
        return date.strftime('%Y-%m-%d')  # or any other format you prefer
    return None

def get_user_classes_using_classId(event, context):
    # Database connection
    connection = pymysql.connect(
        host=os.getenv("DATABASE_ENDPOINT"),
        user=os.getenv("USER_NAME"),
        passwd=os.getenv("PASSWORD"),
        db=os.getenv("DATABASE_NAME")
    )

    # Extract user UID from the event
    if 'queryStringParameters' in event and event['queryStringParameters']:
        class_id = event['queryStringParameters'].get("ClassId")
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Missing class id query parameter')
        }

    try:
        with connection.cursor() as cursor:
            # SQL to fetch classes where the user is enrolled
            sql = """
                SELECT * FROM Classes WHERE ClassID == %s
            """
            cursor.execute(sql, (class_id,))
            classes = cursor.fetchall()

            # Format the result as a list of dictionaries
            classes_list = []
            for cls in classes:
                class_info = {
                    'ClassId': cls[0],
                    'ClassName': cls[1],
                    'Description': cls[2],
                    'CreationDate': serialize_date(cls[3]),
                    'TeacherId': cls[4],
                    'ClassCode': cls[5]  # assuming you have a ClassCode field
                }
                classes_list.append(class_info)

            return {
                'statusCode': 200,
                'body': json.dumps(classes_list)
            }

    except Exception as e:
        logger.error("Error fetching user's classes: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps('Error fetching classes')
        }

    finally:
        connection.close()
