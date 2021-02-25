import json


def is_string_number(s: str):
    try:
        int(s)
        return True
    except:
        return False


def is_question_number(s: str):
    if s.endswith('.') and is_string_number(s[:-1]):
        return True
    return False


def fix():
    with open('data.txt', 'r') as reader:
        word_by_word = reader.read().split()
        idx = 0
        questions = []
        while idx < len(word_by_word):
            while idx < len(word_by_word) and not is_question_number(word_by_word[idx]):
                idx += 1
            question = ""
            print(f"Question number {word_by_word[idx]}.")

            while not word_by_word[idx].startswith('a)'):
                question += word_by_word[idx] + " "
                idx += 1
            ans = {'a': "", 'b': "", 'c': "", 'd': ""}
            while not word_by_word[idx].startswith('b)'):
                ans['a'] += word_by_word[idx] + " "
                idx += 1
            while not word_by_word[idx].startswith('c)'):
                ans['b'] += word_by_word[idx] + " "
                idx += 1
            while not word_by_word[idx].startswith('d)'):
                ans['c'] += word_by_word[idx] + " "
                idx += 1
            while (idx < len(word_by_word)) and not is_question_number(word_by_word[idx]):
                ans['d'] += word_by_word[idx] + " "
                idx += 1
            questions.append(
                Question(question, [ans['a'], ans['b'], ans['c'], ans['d']]))
        return questions


def questions_to_file(file_name, questions):
    with open(file_name, 'w') as writer:
        for question in questions:
            writer.write(str(question) + '\n')


class Question:
    def __init__(self, question, answers, correct_answer=0, question_number=0):
        self.question = question
        self.answers = answers
        self.correct_answer = correct_answer
        self.question_number = int(question.split('.')[0])

    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__,
                          sort_keys=True, indent=4)

    def set_correct_answer(self, s):
        self.correct_answer = ord(s[0]) - ord('a')

    def __str__(self):
        ret = self.question + '\n'
        for i, ans in enumerate(self.answers):
            ret += ans
            if i == self.correct_answer:
                ret += ' <----- CORRECT'
            ret += '\n'
        return ret

    def get_correct(self):
        return self.answers[self.correct_answer]

    def str_without_answer(self):
        ret = self.question + '\n'
        for i, self.answers in enumerate(self.answers):
            ret += self.answers + '\n'
        return ret


def gen_data_with_answers(questions):
    for question in questions:
        print(question.str_without_answer())
        correct = input('Correct answer is: [a, b, c, d] ')
        while len(correct) == 0 or ord(correct[0]) < ord("a"[0]) or ord(correct[0]) > ord("d"[0]):
            correct = input('Try again: ')
        question.set_good_answer(correct)
    return questions


def serialize_answers(file_name, questions):
    with open(file_name, 'w') as writer:
        writer.write(json.dumps([qu.__dict__ for qu in questions]))


def generate_answers():
    questions = fix()
    try:
        gen_data_with_answers(questions)
    except:
        pass
    serialize_answers("answers.json", questions)


def get_answers_from_json():
    with open('answers.json', 'r') as reader:
        js = reader.read()
        q = json.loads(js)
        questions = []
        for quest in q:
            questions.append(Question(**quest))
        return questions


generate_answers()
