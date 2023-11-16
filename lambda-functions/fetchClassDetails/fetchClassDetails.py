import json
import os
import pymysql
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def serialize_date(date):
    if date:
        return date.strftime('%Y-%m-%d') 
    return None

def get_user_classes(event, context):
  
    connection = pymysql.connect(
        host=os.getenv("DATABASE_ENDPOINT"),
        user=os.getenv("USER_NAME"),
        passwd=os.getenv("PASSWORD"),
        db=os.getenv("DATABASE_NAME")
    )

    
    if 'queryStringParameters' in event and event['queryStringParameters']:
        user_uid = event['queryStringParameters'].get("UserId")
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Missing userUID query parameter')
        }

    try:
        with connection.cursor() as cursor:
           
            sql = """
                SELECT Classes.* FROM Classes
                JOIN Enrollments ON Classes.ClassId = Enrollments.ClassId
                WHERE Enrollments.UserId = %s
            """
            cursor.execute(sql, (user_uid,))
            classes = cursor.fetchall()

            
            classes_list = []
            for cls in classes:
                class_info = {
                    'ClassId': cls[0],
                    'ClassName': cls[1],
                    'Description': cls[2],
                    'CreationDate': serialize_date(cls[3]),
                    'TeacherId': cls[4],
                    'ClassCode': cls[5] 
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
