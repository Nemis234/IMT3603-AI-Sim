
hei = "adisjkd"
morn = "fkmekjmf"

dict = {}

key1 = frozenset((hei, morn))
key2 = frozenset((morn, hei))

dict[key1] = [1,2,3]
dict[key2] = [4,5,6]

print(dict)
