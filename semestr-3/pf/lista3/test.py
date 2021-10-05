import json
from fix import *
import tkinter as tk
import random
import time


random.seed(time.time())
HEIGHT = 700
WIDTH = 800


class Quiz():
    def __init__(self, questions):
        self.questions = dict()
        for question in questions:
            self.questions[question.question_number] = question
        self.first_question = 1
        self.asked_questions = []
        self.correct_answers = 0
        self.current_question = self.get_random_question()

    def get_question(self, nr):
        self.asked_questions.append(nr)
        self.current_question = self.questions[nr]
        return self.questions[nr]

    def get_random_question(self, unasked=True):
        question = random.choice(list(self.questions.values()))
        if unasked:
            while question.question_number in self.asked_questions:
                question = random.choice(list(self.questions.values()))
        self.asked_questions.append(question.question_number)
        self.current_question = question
        return question

    def reset(self):
        self.asked_questions = []
        self.correct_answers = 0

    def answer_question(self, question, answer):
        if answer == question.correct_answer:
            self.correct_answers += 1
        return question.correct_answer


def begin_quiz(root):
    quiz = Quiz(get_answers_from_json())

    quiestion_frame = tk.Frame(root, bd=1)
    quiestion_frame.place(relx=0.05, rely=0.1, relwidth=0.9, relheight=0.7)

    question_label = tk.Label(
        quiestion_frame, text=quiz.current_question.str_without_answer(), font='Helvetica 12', wraplength=550, justify='left')
    question_label.place(relx=0.1, rely=0.1, relwidth=0.8, relheight=0.8)

    stats_frame = tk.Frame(root, bg='white', bd=5)
    stats_frame.place(relx=0.7, rely=0.85, relwidth=0.25, relheight=0.1)

    correct_label = tk.Label(stats_frame, text='Poprawne: 0', font=20)
    correct_label.place(relx=0.05, rely=0.15, relwidth=0.9, relheight=0.2)

    answered_label = tk.Label(stats_frame, text='Zadane: 1', font=20)
    answered_label.place(relx=0.05, rely=0.40, relwidth=0.9, relheight=0.2)

    wr_label = tk.Label(stats_frame, text='Procent dobrych: 0%', font=20)
    wr_label.place(relx=0.05, rely=0.7, relwidth=0.9, relheight=0.2)

    answers_frame = tk.Frame(root, bg='white', bd=5)
    answers_frame.place(relx=0.05, rely=0.85, relheight=0.1, relwidth=0.60)

    answer_buttons = []

    def next_question(next_question_button):
        for button in answer_buttons:
            button.configure(bg='grey')
        next_question_button.place_forget()
        quiz.get_random_question()
        question_label.configure(
            text=quiz.current_question.str_without_answer())
        answered_label.configure(text=f"Zadanie: {len(quiz.asked_questions)}")

    next_question_button = tk.Button(
        answers_frame, bg='grey', text='Następne', font='Helvetica 18 bold', command=lambda: next_question(next_question_button))

    def answer_question(answer):
        quiz.answer_question(quiz.current_question, answer)
        correct = quiz.current_question.correct_answer
        if correct != answer:
            answer_buttons[answer].configure(bg='red')
        else:
            correct_label.configure(
                text=f"Poprawne: {quiz.correct_answers}")
        wr_label.configure(
            text="Procent dobrych: {:.2f}%".format(round((quiz.correct_answers/(len(quiz.asked_questions)) * 100.0), 2)))
        answer_buttons[correct].configure(bg='green')
        next_question_button.place(relx=0.525, relheight=0.9)

    buttonA = tk.Button(answers_frame, text='a', bg='grey',
                        font='Helvetica 18 bold', command=lambda: answer_question(0))
    buttonA.place(relx=0.025, relwidth=0.1, relheight=0.9)

    buttonB = tk.Button(answers_frame, text='b', bg='grey',
                        font='Helvetica 18 bold', command=lambda: answer_question(1))
    buttonB.place(relx=0.15, relwidth=0.1, relheight=0.9)

    buttonC = tk.Button(answers_frame, text='c', bg='grey',
                        font='Helvetica 18 bold', command=lambda: answer_question(2))
    buttonC.place(relx=0.275, relwidth=0.1, relheight=0.9)

    buttonD = tk.Button(answers_frame, text='d', bg='grey',
                        font='Helvetica 18 bold', command=lambda: answer_question(3))
    buttonD.place(relx=0.4, relwidth=0.1, relheight=0.9)

    answer_buttons += [buttonA, buttonB, buttonC, buttonD]


def __main__():
    root = tk.Tk()

    canvas = tk.Canvas(root, height=HEIGHT, width=WIDTH)
    canvas.pack()

    background_image = tk.PhotoImage(file='ktos.png')
    background_label = tk.Label(root, image=background_image)
    background_label.place(x=0, y=0, relwidth=1, relheight=1)

    def begin():
        button.place_forget()
        begin_quiz(root)

    button = tk.Button(root, text="Zacznij zabawę",
                       font=40, command=begin)
    button.place(relx=0.5, rely=0.5, anchor='n')

    root.mainloop()


__main__()
