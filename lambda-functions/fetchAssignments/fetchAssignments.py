import json
import os
import pymysql
import logging
import base64

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_assignments_for_class(event, context):
    
    connection = pymysql.connect(
        host=os.getenv("DATABASE_ENDPOINT"),
        user=os.getenv("USER_NAME"),
        passwd=os.getenv("PASSWORD"),
        db=os.getenv("DATABASE_NAME")
    )

    # Extract class ID from the event
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
                SELECT AssignmentId, Title, Description, DueDate, PostedDate, Attachment
                FROM Assignments
                WHERE ClassId = %s
            """
            cursor.execute(sql, (class_id,))
            assignments = cursor.fetchall()

           
            assignments_list = []
            for assignment in assignments:
               
                attachment = base64.b64encode(assignment[5]).decode('utf-8') if assignment[5] else None

            

                assignment_info = {
                    'AssignmentId': assignment[0],
                    'Title': assignment[1],
                    'Description': assignment[2],
                    'DueDate': assignment[3].strftime('%Y-%m-%d %H:%M:%S') if assignment[3] else None,
                    'PostedDate': assignment[4].strftime('%Y-%m-%d %H:%M:%S') if assignment[4] else None,
                    'Attachment': attachment
                }
                assignments_list.append(assignment_info)

            return {
                'statusCode': 200,
                'body': json.dumps(assignments_list)
            }

    except Exception as e:
        logger.error("Error fetching assignments: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps('Error fetching assignments')
        }

    finally:
        connection.close()
