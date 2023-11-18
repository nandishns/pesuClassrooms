import json
import os
import pymysql
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def save_details(event, context):
    # Connection
    connection = pymysql.connect(
        host=os.getenv("DATABASE_ENDPOINT"), 
        user=os.getenv("USER_NAME"), 
        passwd=os.getenv("PASSWORD"), 
        db=os.getenv("DATABASE_NAME")
    )
    logger.info("Received event: %s", event)


    if 'queryStringParameters' in event and event['queryStringParameters']:
        queryParams = event['queryStringParameters']
        UserId = queryParams.get("UserId")
        FirstName = queryParams.get("FirstName")
        LastName = queryParams.get("LastName")
        Email = queryParams.get("Email")
        JoiningDate = queryParams.get("JoiningDate")
        PhotoUrl = queryParams.get("photoUrl")
    else:
        logger.error("No query parameters provided")
        return {
            'statusCode': 400,
            'body': json.dumps('No query parameters provided')
        }

    if not all([UserId, FirstName, LastName, Email, JoiningDate, PhotoUrl]):
        logger.error("Missing one or more required fields")
        return {
            'statusCode': 400,
            'body': json.dumps('Missing one or more required fields')
        }

  
    try:
        with connection.cursor() as cursor:
            #SQL query to INSERT a record into the database.
            sql = """
                INSERT INTO User (UserId, FirstName, LastName, Email, JoiningDate, PhotoUrl) 
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (UserId, FirstName, LastName, Email, JoiningDate, PhotoUrl))

            # Commit the changes
            connection.commit()

            return {
                'statusCode': 200,
                'body': json.dumps('User saved successfully')
            }

    except Exception as e:
        logger.error("Error saving user details: %s", e)
        return {
            'statusCode': 500,
            'body': json.dumps('Error saving user details')
        }

    finally:
        connection.close()
