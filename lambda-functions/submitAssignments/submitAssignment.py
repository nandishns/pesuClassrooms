import json
import os
import pymysql
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def submit_assignment(event, context):
    
    connection = pymysql.connect(
        host=os.getenv("DATABASE_ENDPOINT"),
        user=os.getenv("USER_NAME"),
        passwd=os.getenv("PASSWORD"),
        db=os.getenv("DATABASE_NAME")
    )

    # Extract submission details from the event
    if 'queryStringParameters' in event and event['queryStringParameters']:
        queryParams = event['queryStringParameters']
        assignment_id = queryParams.get("AssignmentId")
        user_id = queryParams.get("UserId")
        submission_text = queryParams.get("SubmissionText")
        submission_file_url = queryParams.get("SubmissionFileURL")  
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Missing submission details')
        }

    try:
        with connection.cursor() as cursor:
            
            sql = """
                INSERT INTO Submissions (AssignmentId, UserId, SubmissionText, SubmissionFileURL)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(sql, (assignment_id, user_id, submission_text, submission_file_url))

            
            connection.commit()

            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'Submission recorded successfully'})
            }

    except Exception as e:
        logger.error("Error recording submission: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps('Error recording submission')
        }

    finally:
        connection.close()
