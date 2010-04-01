import("PrintRecursive")

--local a = bit.and(0xffff,0xf0f0)
print(string.format("%x & %x == %x", 0x0fff, 0xfff0,bit.band(0x0fff,0xfff0)))
print(string.format("%x | %x == %x", 0x0f0f, 0xf0f0,bit.bor(0x0f0f,0xf0f0)))
print(string.format("%x ^ %x == %x", 0xffff, 0xf0f0,bit.bxor(0xffff,0xf0f0)))
print(string.format("~%x == %x", 0xf0f0,bit.bnot(0xf0f0)))
print(string.format("%x << %d == %x", 0xffff, 4,bit.lshift(0xffff,4)))
print(string.format("%x >> %d == %x", 0xffff, 4,bit.rshift(0xffff,4)))