import openai
from openai_multi_client import OpenAIMultiClient, Payload

openai.api_key = 'api_key'  # Replace with your OpenAI API key

input_file_path = "input .txt file path"  # Replace with the path to your input file
output_file_path = "output .csv file path"  # Replace with the path to the output CSV file

api = OpenAIMultiClient(concurrency=15, max_retries=40, wait_interval=30, endpoint="chats", data_template={"model": "gpt-3.5-turbo"})

def on_result(result: Payload):
	line = result.metadata['line']
	response = result.response['choices'][0]['message']['content']

	# Append the result to the output_data list
	output_data.append([line, response])
	write_output_to_csv()
        
def write_output_to_csv():
    with open(output_file_path, "a", newline="") as file:
        writer = csv.writer(file)
        writer.writerows(output_data)

    # Clear the output_data list after writing to the CSV file
    output_data.clear()


def make_requests():
    with open(input_file_path, "r") as file:
        lines = file.readlines()

    for line in lines:
        line = line.strip("\n")
        messages = []
        messages = [{"role": "system", "content": "ENTER SYSTEM MESSAGE HERE"},
        	{"role": "user", "content": f"ENTER USER PROMPT HERE"}]

        api.request(data={"messages": messages, "presence_penalty": -1.0}, metadata={'line': line}, callback=on_result)


output_data = []  # List to store the generated output

api.run_request_function(make_requests)
api.pull_all()

# Write any remaining output_data to the CSV file
write_output_to_csv()
