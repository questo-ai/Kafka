import spacy

nlp = spacy.load("en_core_web_sm")

def spacy_dump_to_conll(sentence):
	'''
	Notes about spacy/conll:
	- spacy: root is only token that "self-headed"
	- conll: root refers to null token (0)

	- conll (case) == spacy (pobj), except direction of head is switched
	- conll (cop) == spacy (attr)
	'''

	doc = nlp(sentence)
	tokens = doc.to_json()['tokens']
	conll_representation = [(token['head']+1, token['id']+1, token['dep']) for token in tokens]

	return conll_representation


def get_testing_sentences(number_of_cases=10):
	'''
	Returns a tuple of sentences and their spacy output in conll format.
	'''
	from test_sentences import test_sentences

	to_return = []

	for sentence_c in range(number_of_cases):
		sentence = test_sentences[sentence_c]
		conll = spacy_dump_to_conll(sentence)
		to_return.append((sentence, conll))

	return to_return

if __name__ == "__main__":
	from pprint import pprint
	# print(spacy_dump_to_conll("Goh Chok Tong was passed the reins of leadership by Lee Kuan Yew in 1990."))
	pprint(get_testing_sentences())