
import pandas as pd

df = pd.read_csv("/home/june/Desktop/OpenAI/output0.7.csv")
df =df.iloc[:, :6]
df.columns = ['Original', 'Variation 1', 'Variation 2', 'Variation 3', 'Variation 4', 'Variation 5']

# Function to extract rows out of dataframe
def extract_row_as_list(dataframe, row_index):
  # Extract the specified row from the dataframe
  row = dataframe.iloc[row_index]

  # Convert the row values to a list
  row_list = row.tolist()

  # Remove any NaN values from the list
  row_list = [str(value) for value in row_list if pd.notnull(value)]

  return row_list


# Function to get the top three indexes
def get_top_indexes(array, k):
  # Flatten the array
  flattened_array = array.flatten()
  # Get the indexes of the top k values in descending order
  top_indexes = np.argsort(flattened_array)[::-1][:k]

  return top_indexes

model = SentenceTransformer('distiluse-base-multilingual-cased-v2')

df = df.dropna().reset_index(drop=True)

good_sentences = []
for i in range(len(df)):
  sentences = extract_row_as_list(df, i)
  good_sentences.append(sentences[0])
  sentence_embeddings = model.encode(sentences)
  cosine_similarity_value = cosine_similarity([sentence_embeddings[0]], sentence_embeddings[1:])
  indexes = get_top_indexes(cosine_similarity_value, 3)
  top_3_sentences = []
  for index in indexes:
    #top_3_sentences.append(sentences[index])
    good_sentences.append(sentences[index])
  print(len(good_sentences)//4)

with open("1cs_0.9_output", "w", encoding = "utf-8") as file:
  for sentence in good_sentences:
    file.write(sentence + "\n")
