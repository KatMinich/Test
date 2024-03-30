# Задание 1

class First:
    def getClassname(self):
        print("First")

    def getLetter(self):
        print("A")


class Second:
    def getClassname(self):
        print("Second")

    def getLetter(self):
        print("B")


#Задание 2

import re

input_string = (" ***/Test/files/1.xls, ***/Test/files/2.XLSX,***/Test/files/9.vra, "
                "***/Test/files/3.jpg, ***/Test/files/4.xml, ***/Test/files/5.png, "
                "***/Test/files/6.xlsm, ***/Test/files/7.xlso, ***/Test/files/8.xls*, "
                "***/Test/files/9.xlasx, ***/Test/files/9.vba")

# регулярное выражение для поиска форматов Excel
excel_formats = re.findall(r'\S+\.xls\w*', input_string)

result = ",".join(excel_formats)
print(result)

#Задание 3

import sys

def sort_numbers(input_string):
    numbers = []

    # разделяем входную строку на отдельные элементы по пробелу
    elements = input_string.split()

    for element in elements:
        try:
            # преобразовываем элемент в число и добавляем в список чисел
            number = float(element)
            numbers.append(number)
        except ValueError:
            # если элемент не является числом, то пропускаем его
            continue

    # сортируем список чисел по возрастанию
    sorted_numbers = sorted(numbers)

    return sorted_numbers

