import json
import os
import pymysql
import logging
import base64

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def create_assignment(event, context):
    
    connection = pymysql.connect(
        host=os.getenv("DATABASE_ENDPOINT"),
        user=os.getenv("USER_NAME"),
        passwd=os.getenv("PASSWORD"),
        db=os.getenv("DATABASE_NAME")
    )

  
    if 'queryStringParameters' in event and event['queryStringParameters']:
        queryParams = event['queryStringParameters']
        class_id = queryParams.get("ClassId")
        title = queryParams.get("Title")
        description = queryParams.get("Description")
        due_date = queryParams.get("DueDate")  
        attachment = queryParams.get("Attachment")
        attachment_binary = base64.b64decode(attachment) if attachment else None
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Missing request body')
        }

    try:
        with connection.cursor() as cursor:
          
            sql = """
                INSERT INTO Assignments (ClassId, Title, Description, DueDate, Attachment)
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (class_id, title, description, due_date, attachment_binary))

          
            connection.commit()

            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Assignment created successfully'})
            }

    except Exception as e:
        logger.error("Error creating assignment: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps('Error creating assignment')
        }

    finally:
        connection.close()
