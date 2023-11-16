import json
import os
import pymysql
import logging
import random
import string
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def generate_class_code(size=6):
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=size))

def create_class(event, context):
    
    connection = pymysql.connect(
        host=os.getenv("DATABASE_ENDPOINT"),
        user=os.getenv("USER_NAME"),
        passwd=os.getenv("PASSWORD"),
        db=os.getenv("DATABASE_NAME")
    )

    
    if 'queryStringParameters' in event and event['queryStringParameters']:
        queryParams = event['queryStringParameters']
        class_name = queryParams.get("className")
        description = queryParams.get("description")
        teacher_id = queryParams.get("teacherId")  
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Missing query parameters')
        }

    
    creation_date = datetime.now().strftime('%Y-%m-%d')
    class_code = generate_class_code()

    try:
        with connection.cursor() as cursor:
            
            sql = """
                INSERT INTO Classes (ClassName, Description, CreationDate, TeacherId, ClassCode)
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (class_name, description, creation_date, teacher_id, class_code))
            class_id = cursor.lastrowid

            
            sql = """
                INSERT INTO Enrollments (UserId, ClassId, Role)
                VALUES (%s, %s, 'teacher')
            """
            cursor.execute(sql, (teacher_id, class_id))

            
            connection.commit()

            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Class created successfully', 'classId': class_id, 'classCode': class_code})
            }

    except Exception as e:
        logger.error("Error creating class: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps('Error creating class')
        }

    finally:
        connection.close()
