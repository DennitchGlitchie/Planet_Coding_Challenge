# File: PlanetDictionaryAnagrams.py
# Name: David Garges
# Date: 11/16/17
# Desc:         This program takes a dictionary file as an input (one word per line)
#               and ouputs sets of anagrams in which there are at least 4 letters
#               in the word and at least as many anagrams as there are letters

# Method:       This program utilizes a hashtable who's hashfunction groups words
#               together by the sum of their ASCII values - this groups anagrams together.
#               While avoiding duplicate outputs, the program explores each element of the 
#               hashtable alphabetically and grabs and outputs anagram sets. This takes
#               about 10min to complete for 200k words.

# Improvements: Hash function can be improved to better disperse anagrams sets. The
#               max ASCII of a 9 letter word is 1098 so 200k words will only map to a (rough)
#               ~1000 indexes in the hash table. Would be cool to map words such that they
#               are grouped by anagrams but also more evenly dispursed. 
#       

# Input Variables
DICTIONARY_FILE = "Dictionary.txt"

# Defining Global Variables
LENTH_OF_DICTIONARY = sum(1 for line in open(DICTIONARY_FILE))

# Defining ASCII-sum Hashmap class
# Each element contains the dictionary word and a "breadcrumb" value
class HashMap:
    # Size of Hashmap chosen based off of average values of words
    def __init__(self):
        self.size = 1000 # Size of hash based off of max/average ASCII sum
        self.map = [None] * self.size

    # Hash function based on sum of ASCII values of each character in string
    def _get_hash(self, key):
        hash = 0
        for char in str(key):
            hash += ord(char)
        return hash % self.size

    # This is a straightforward add function
    def add(self, key, value):
        key_hash = self._get_hash(key)
        key_value = [key, value]

        if self.map[key_hash] is None:
            self.map[key_hash] = list([key_value])
            return True
        else:
            for pair in self.map[key_hash]:
                if pair[0] == key:
                    pair[1] = value
                    return True
                self.map[key_hash].append(key_value)
                return True

    # This is a straightforward get function
    def get(self, key):
        key_hash = self._get_hash(key)
        if self.map[key_hash] is not None:
            for pair in self.map[key_hash]:
                if pair[0] == key:
                    return pair[1]
        return None

    # This is a straightforward exists function
    def exists(self, key):
        key_hash = self._get_hash(key)

        if self.map[key_hash] is None:
            return False
        else:
            for pair in self.map[key_hash]:
                if pair[0] == key:
                    return True
        return False
        
    # This is a straightforward delete function utilizing .pop
    def delete(self, key):
        key_hash = self._get_hash(key)

        if self.map[key_hash] is None:
            return False
        for i in range (0, len(self.map[key_hash])):
            if self.map[key_hash][i][0] == key:
                self.map[key_hash].pop(i)
                return True

    # This function outputs a list of anagrams for the given word IF words haven't been listed already
    def getAnagrams(self, key):
        key_hash = self._get_hash(key)

        #create empty list to add anagrams
        AnagramSetList = list()
        if self.map[key_hash] is None:
            return AnagramSetList
        
        for i in range (0, len(self.map[key_hash])):
            #check for breadcrumb (have we looked at this word already?)
            #This helps avoid outputting duplicate anagram sets
            if self.map[key_hash][i][1] == 0:
                if sorted(key) == sorted(self.map[key_hash][i][0]):
                    AnagramSetList.append(self.map[key_hash][i][0])
                    self.map[key_hash][i][1] = 1 #leave breadcrumb
        return AnagramSetList
            

    # This function prints all elements in the hashmap helpful for debugging
    def printit(self):
        print('---DICTIONARY---')
        for item in self.map:
            if item is not None:
                print(str(item))
#___Starting Main Routine____________________________________________________

# The total number of words in dictionary.txt is 235886
# The total number of >=4 words in dictionary.txt is 234254
dictionary = HashMap()
f = open(DICTIONARY_FILE,'r')

# Map all words with length >= 4 in the dictionary to HashMap
for i in range(1, LENTH_OF_DICTIONARY):
    word = f.readline()
    word = word.rstrip('\n')
    if len(word) >= 4: 
        dictionary.add(word,0)

# Alphabetically check all emelements in the hash for sets of anagrams
g = open("Dictionary.txt",'r')
for i in range(1, LENTH_OF_DICTIONARY):
    word = g.readline()
    word = word.rstrip('\n')
    if len(word) >= 4:
        anagrams = dictionary.getAnagrams(word)
        if len(anagrams) >= len(word):
            print ', '.join(anagrams)



