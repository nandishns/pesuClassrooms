import json
import os
import pymysql
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def get_user_classes(event, context):
    # Database connection
    connection = pymysql.connect(
        host=os.getenv("DATABASE_ENDPOINT"),
        user=os.getenv("USER_NAME"),
        passwd=os.getenv("PASSWORD"),
        db=os.getenv("DATABASE_NAME")
    )

    
    if 'queryStringParameters' in event and event['queryStringParameters']:
        class_id = event['queryStringParameters'].get("ClassId")
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Missing ClassId query parameter')
        }

    try:
        with connection.cursor() as cursor:
           
            sql = """
                CALL GetClassMembers(%s);
            """
            cursor.execute(sql, (class_id))
            result = cursor.fetchall()

          
            formatted_result = []
            for row in result:
                member_info = json.loads(row[0])
                formatted_result.append(member_info)


            return {
                'statusCode': 200,
                'body': json.dumps(formatted_result)
            }

    except Exception as e:
        logger.error("Error fetching members details: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps('Error fetching classes')
        }

    finally:
        connection.close()
