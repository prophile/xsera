table.print_recursive = function (t, indent) -- alt version, abuse to http://richard.warburton.it
  local indent=indent or ''
  for key,value in pairs(t) do
    io.write(indent,'[',tostring(key),']') 
    if type(value)=="table" then io.write(':\n') table.print_recursive(value,indent..'\t')
    else io.write(' = ',tostring(value),'\n') end
  end
end
