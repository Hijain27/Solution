# -*- coding: utf-8 -*-
#Challenge #3
#We have a nested object. We would like a function where you pass in the object and a key and get back the value.
#object = {“a”:{“b”:{“c”:”d”}}}
#key = a/b/c
#object = {“x”:{“y”:{“z”:”a”}}}
#key = x/y/z
#value = a

def getValue(_dict, keys, default=None):
    for key in keys:
        #print(keys)
        if isinstance(_dict,dict):
            _dict = _dict.get(key)
            #print(_dict)
        else:
            return default
    return _dict

obj = {"x":{"y":{"z":"a"}}}
print getValue(obj,['x','y','z'])

#object = {"a":{"b":{"c":"d"}}}
#print getValue(obj,['a','b','c'])
