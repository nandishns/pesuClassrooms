import json
import os
import pymysql
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def join_class(event, context):
    # Database connection
    connection = pymysql.connect(
        host=os.getenv("DATABASE_ENDPOINT"),
        user=os.getenv("USER_NAME"),
        passwd=os.getenv("PASSWORD"),
        db=os.getenv("DATABASE_NAME")
    )
    joinedAt = datetime.now().strftime('%Y-%m-%d')

    # Check if query parameters are provided
    if 'queryStringParameters' in event and event['queryStringParameters']:
        queryParams = event['queryStringParameters']
        user_id = queryParams.get("UserId")
        class_code = queryParams.get("ClassCode")
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Missing query parameters')
        }

    try:
        with connection.cursor() as cursor:
           
            sql = "SELECT ClassId FROM Classes WHERE ClassCode = %s"
            cursor.execute(sql, (class_code,))
            result = cursor.fetchone()
            
            if result:
                class_id = result[0]

                
                sql = """
                    INSERT INTO Enrollments (UserId, ClassId, Role,JoinedAt)
                    VALUES (%s, %s,%s, 'student')
                """
                cursor.execute(sql, (user_id, class_id,joinedAt))

               
                connection.commit()

                return {
                    'statusCode': 200,
                    'body': json.dumps({'message': 'Successfully joined the class'})
                }
            else:
                return {
                    'statusCode': 404,
                    'body': json.dumps({'message': 'Class code not found'})
                }

    except Exception as e:
        logger.error("Error joining class: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps('Error joining class')
        }

    finally:
        connection.close()
