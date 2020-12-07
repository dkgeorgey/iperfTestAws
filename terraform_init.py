import os
import logging
import json
import boto3
import time

# Set the logging configuration
logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.INFO)
global instance_type_1, instance_type_2

# getting the instance types from user
instance_type_1 = input("What is the instance type of EC2 Instance #1?\n")
instance_type_2 = input("What is the instance type of EC2 Instance #2?\n")


def get_aws_creds():
    """
    This function sets the aws creds in the environment
    """
    try:
        aws_access_key_id = input("Enter AWS Access Key ID:\n")
        aws_secret_access_key = input("Enter AWS Secret Access Key:\n")
        aws_region = input("Enter AWS Region:\n")
        os.environ['AWS_ACCESS_KEY_ID'] = aws_access_key_id
        os.environ['AWS_SECRET_ACCESS_KEY'] = aws_secret_access_key
        os.environ['AWS_DEFAULT_REGION'] = aws_region
    except Exception as error:
        logger.info(f"Error in setting aws creds: {error}")


def create_tf_resources():
    """
    This function creates the required tf resources
    """
    global instance_type_1, instance_type_2
    try:
        instance_types = json.dumps([instance_type_1, instance_type_2])
        os.system("terraform init")
        os.environ['TF_VAR_instance_type'] = instance_types
        os.system("terraform plan")
        os.system("terraform apply -auto-approve")
    except Exception as error:
        logger.info(f"Error in creating tf resources: {error}")


def destroy_tf_resources():
    """
    This function deletes the tf resources
    """
    try:
        os.system("terraform destroy -auto-approve")
    except Exception as error:
        logger.info(f"Error in destroying tf resources: {error}")

def install_prereqs():
    """
    Installing the prerequisites for the program to work
    """
    try:
        os.system("git clone https://github.com/tfutils/tfenv.git ~/.tfenv")
        os.system("echo 'export PATH=\"$HOME/.tfenv/bin:$PATH\"' >> ~/.bash_profile")
        os.system("ln -s ~/.tfenv/bin/* /usr/local/bin")
        os.system("tfenv install 0.12.10")
        os.system("pip3 install -r requirements.txt")
    except Exception as error:
        logger.info(f"Error in installing prerequisites: {error}")


def get_s3_files(s3_client, bucket_name):
    """
    This function gets the iperf3 results from s3
    :param s3_client: An initialised boto3 client for s3
    :param bucket_name: name of the s3 bucket
    :return:  list of the filenames
    """
    file_names = []
    try:
        # sleeping for 90 secs to wait for the files to be uploaded
        time.sleep(90)
        list_of_objects = s3_client.list_objects(Bucket=bucket_name)['Contents']
        for each_object in list_of_objects:
            with open(each_object['Key'], 'wb') as data:
                s3_client.download_fileobj(bucket_name, each_object['Key'], data)
                file_names.append(each_object['Key'])
        return file_names
    except KeyError:
        pass  


def get_s3_bucket(s3_client):
    """
    This function gets the iperf3 results from s3
    :param s3_client: An initialised boto3 client for s3
    :return:  get bucket name
    """
    buckets = s3_client.list_buckets()['Buckets']
    for bucket in buckets:
        try:
            tag_set = s3_client.get_bucket_tagging(Bucket=bucket['Name'])['TagSet']
            for tag in tag_set:
                if tag['Key'] == "project" and tag['Value'] == "iperf-test":
                    s3_bucket = bucket['Name']
                    return s3_bucket
        except Exception:
            pass


def delete_s3_objects(s3_client, bucket_name, object_name):
    """
    This function gets the iperf3 results from s3
    :param s3_client: An initialised boto3 client for s3
    :param bucket_name: name of the s3 bucket
    :param object_name: name of the s3 bucket
    :return:  deletes the s3 objects within the bucket
    """
    try:
        response = s3_client.delete_object(
            Bucket=bucket_name,
            Key=object_name
        )
    except Exception as error:
        logger.info(f"Error in deleting s3 objects: {error}")


def read_iperf_file(filename):
    """
    This function gets the iperf3 results from s3
    :param filename: name of the file to read
    :return:  filtered contents of the file which have the throughput data
    """
    global instance_type_1, instance_type_2
    filtered_data = {}
    try:
        sender_data = [line for line in open(filename) if 'sender' in line]
        receiver_data = [line for line in open(filename) if 'receiver' in line]
        if len(sender_data) > 0 and len(receiver_data) > 0:
            sender_raw_data = sender_data[0].split('  ')
            receiver_raw_data = receiver_data[0].split('  ')
            filtered_sender_data = list(filter(None, sender_raw_data))
            filtered_receiver_data = list(filter(None, receiver_raw_data))
            filtered_data['sender'] = filtered_sender_data
            filtered_data['receiver'] = filtered_receiver_data
            return filtered_data
        else:
            print("Received blank file")
    except Exception as error:
        logger.info(f"Error in reading iperf file: {error}")


def display_iperf_results(file_contents):
    """
    This function displays the iperf results
    :param file_contents: contents of the file
    :return:  A string that has to be displayed
    """
    length = len(file_contents)
    try:
        file_contents.pop(length-1)
        if length == 8:
            file_contents.pop(length-2)
        file_contents.pop(0)
        file_contents.pop(0)
        return f"In {file_contents[0]} seconds {file_contents[2]} data was transferred at the rate of {file_contents[-1]}"
    except Exception as error:
        logger.info(f"Error in displaying iperf results: {error}")


def main():
    """
    Main function. This is the entry point into the program
    """
    global instance_type_1, instance_type_2
    #get_aws_creds()
    install_prereqs()
    create_tf_resources()
    bucket_name = ""
    file_names = ""
    s3_client = boto3.client('s3')
    while bucket_name == "":
        print("Waiting for the s3 bucket to be ready")
        bucket_name = get_s3_bucket(s3_client)
    print("Waiting for iperf results to be uploaded")
    file_names = get_s3_files(s3_client, bucket_name)
    for file_name in file_names:
        raw_file_name = file_name.split('.')[0]
        if raw_file_name == "client-to-server":
            print(f"\nTCP throughput between {instance_type_1} and {instance_type_2}:\n")
        else:
            print(f"TCP throughput between {instance_type_2} and {instance_type_1}:\n")
        content = read_iperf_file(file_name)
        print(f"Sending:\n{display_iperf_results(content['sender'])}")
        print(f"Receiving:\n{display_iperf_results(content['receiver'])}\n\n")
        delete_s3_objects(s3_client, bucket_name, file_name)
    input("Press Enter to delete TF\n")
    destroy_tf_resources()


if __name__ == "__main__":
    main()
