import json
import os
import pymysql
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_submissions_for_assignment(event, context):
   
    connection = pymysql.connect(
        host=os.getenv("DATABASE_ENDPOINT"),
        user=os.getenv("USER_NAME"),
        passwd=os.getenv("PASSWORD"),
        db=os.getenv("DATABASE_NAME")
    )

    
    if 'queryStringParameters' in event and event['queryStringParameters']:
        assignment_id = event['queryStringParameters'].get("AssignmentId")
        class_id = event['queryStringParameters'].get("ClassId")
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Missing AssignmentId or ClassId query parameter')
        }

    try:
        with connection.cursor() as cursor:
           
            sql = """
                SELECT Submissions.* FROM Submissions
                JOIN Assignments ON Submissions.AssignmentId = Assignments.AssignmentId
                WHERE Submissions.AssignmentId = %s AND Assignments.ClassId = %s
            """
            cursor.execute(sql, (assignment_id, class_id))
            submissions = cursor.fetchall()

           
            submissions_list = []
            for submission in submissions:
                submission_info = {
                    'SubmissionId': submission[0],
                    'UserId': submission[2],
                    'SubmissionText': submission[3],
                    'SubmissionFileURL': submission[4],
                    'SubmissionDate': submission[5].strftime('%Y-%m-%d %H:%M:%S') if submission[5] else None
                }
                submissions_list.append(submission_info)

            return {
                'statusCode': 200,
                'body': json.dumps(submissions_list)
            }

    except Exception as e:
        logger.error("Error fetching submissions: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps('Error fetching submissions')
        }

    finally:
        connection.close()
