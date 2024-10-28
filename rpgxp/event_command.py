# class EventCommand:
# 	code: int
# 	indent: int
# 	parameters: list

# class Blank(EventCommand):
# 	code = 0

# class ShowText(EventCommand):
# 	code = 101

# 	text: str

# class ShowChoicesCancelType(Enum):
# 	code = 102

#     DISALLOW = 0
#     CHOICE1 = 1
#     CHOICE2 = 2
#     CHOICE3 = 3
#     CHOICE4 = 4
#     BRANCH = 5

# class ShowChoices(EventCommand):
# 	code = 103

# 	choices: list[str]
# 	cancel_type: ShowChoicesCancelType

# class InputNumber(EventCommand):
# 	code = 104

# 	variable_id: ref[Variable]
# 	max_digits: int