import('GlobalVars')
--dofile("PrintRecursive.lua")

-- Splits the text into wrappable strings with a maximum length of maxLength.
-- Returns a table of strings of maxLength length or shorter.
function textWrap(text, font, height, maxLength)
	local done = false
	local numWords
	local words
	local totalLength = graphics.text_length(text, font, height)
	
	print("TOTAL length: " .. totalLength)
	if textIsGoodSize(text, font, height, maxLength) then
		return text, 1
	end
	
	words = textSplit(text)
	numWords = #words
	
	if totalLength / 2 <= maxLength then
		-- try to split the text in half
		text = textSplit(text, 2)
		
		-- TODO: need to check to make sure that these are of appropriate size before returning!!!
		return text, 2
	end
	
	return textJoinSlow(words, font, height, maxLength)
end

function textIsGoodSize(text, font, height, maxLength)
	if type(text) ~= "table" then
		return (graphics.text_length(text, font, height) <= maxLength)
	else
		local i
		for i = 1, #text do
			if not textIsGoodSize(text[i], font, height, maxLength) then
				return false
			end
		end
		return true
	end
end

-- Splits text into totalSeg segments - if totalSeg is not given or greater than
-- the number of words, chop all the words individually. Will divide lines
-- as evenly as possible.
-- Returns a table containing the segments.
function textSplit(text, totalSeg)
	local tempText = {}
	local wordsLeft = 0
	local wordsUsed = 0
	local finalText = {}
	local finalTextCounter = 1
	
	if totalSeg == 1 then
		return text
	end
	
	for word in text:gmatch("%a+%W*%s*") do
		wordsLeft = wordsLeft + 1
		tempText[wordsLeft] = word
	end
	
	if totalSeg ~= nil then
		if totalSeg > wordsLeft then
			return tempText
		end
		local wordsPerSeg = math.floor(wordsLeft / totalSeg)
		while wordsLeft ~= 0 do
			finalText[finalTextCounter] = ""
			if wordsLeft % wordsPerSeg ~= 0 then
				local i = 1
				while i <= wordsPerSeg + 1 do
					finalText[finalTextCounter] = finalText[finalTextCounter] .. tempText[wordsUsed + 1]
					i = i + 1
					wordsUsed = wordsUsed + 1
					wordsLeft = wordsLeft - 1
				end
			else
				local i = 1
				while i <= wordsPerSeg do
					finalText[finalTextCounter] = finalText[finalTextCounter] .. tempText[wordsUsed + 1]
					i = i + 1
					wordsUsed = wordsUsed + 1
					wordsLeft = wordsLeft - 1
				end
			end
			finalTextCounter = finalTextCounter + 1
		end
	else
		finalText = tempText
	end
	
	return finalText
end

-- Takes a bunch of words, stored in the table 'words', and concatenates them
-- one by one until the line is too long. It repeats this until all the words
-- are used.
-- Titled "slow" because other faster methods (estimation using the character
-- "M" as a ruler (the longest character), and also binary search)
function textJoinSlow(words, font, height, maxLength)
	local returnText = { "" }
	local index = 1
	local wordsLeft = #words
	
	returnText[index] = words[#words - wordsLeft + 1]
	wordsLeft = wordsLeft - 1
	
	while wordsLeft ~= 0 do
		if graphics.text_length(returnText[index] .. words[#words - wordsLeft + 1], font, height) > maxLength then
			index = index + 1
			returnText[index] = words[#words - wordsLeft + 1]
		else
			returnText[index] = returnText[index] .. words[#words - wordsLeft + 1]
		end
		wordsLeft = wordsLeft - 1
	end
	return returnText, index
end