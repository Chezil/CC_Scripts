local function clrScreen()
  term.clear()
  term.setCursorPos(1,1)
end

local function getAllItems()
  tab = {}
  chest = peripheral.wrap("left")
  items = chest.getAllStacks()
  for i,v in pairs(items) do 
    tmp = v.basic()
    table.insert(tab,i,{tmp.display_name, tmp.qty})
  end
  return tab
end

local function specQuant(table, key)
  for sqKeys, sqVal in pairs(table) do
    if sqVal[1] == key then
      return sqVal[2]
    end
  end
  return 0
end

local function getQuantities()
  items = getAllItems()
  tab = {}
  for i,v in pairs(items) do 
    if #tab == 0 then
      table.insert(tab, {v[1], v[2]})
    else
      notAdded = true
      for j,k in pairs(tab) do
        if(k[1] == v[1]) then
          k[2] = k[2] + v[2]
          notAdded = false
        end
      end
      if notAdded then
        table.insert(tab, {v[1], v[2]})
      end
    end
  end
  return tab
end
local function getSlotByName(name)
  items = getAllItems()
  for k,v in pairs(items) do
    if v[1] == name then
      return k
    end
  end
  return -1
end
local function moveQuant(name, amount, dir)
  cnt = 0
  chest = peripheral.wrap("left")
  while cnt < amount do
    slot = getSlotByName(name)
    cnt = cnt + chest.pushItem(dir, slot, amount - cnt)
  end    
end

local function getSet(alloyList)
  con = peripheral.wrap("back")
  size = con.getInfo().capacity
  items = getQuantities()
  sets = {}
  for k,v in pairs(alloyList) do
    maxSets = math.floor(size / v.produces)
    setnum = maxSets
    for i,j in pairs(v.items) do
      quant = specQuant(items, j[1])
      setnum = math.min(setnum, math.floor(quant / j[2]))
    end
    if setnum > 0 then
      tot = 0
      slotNums = con.getInventorySize()
      for i,j in pairs(v.items) do
        tot = tot + tonumber(j[2])
      end
      if math.floor(slotNums / tot) < setnum then
        setnum = math.floor(slotNums / tot)
      end
      for i,j in pairs(v.items) do
        moveQuant(j[1], tonumber(j[2]) * setnum, "DOWN")
      end
      return tostring(k)..": "..tostring(setnum)
    end
  end 
    return "Waiting for task..."
end

local function logic(alloyList)
  con = peripheral.wrap("back")
  if task == nil then
    task = "Error: Task was reset. Cleaning up..."
  end
  if #con.getAllStacks() == 0 then
    if con.getInfo().contents == nil then
      redstone.setAnalogOutput("right",0)
      task = getSet()
      clrScreen()
      print("Task: "..task)
    else
      redstone.setAnalogOutput("right",15)
      clrScreen()
      print("Task: "..task)
      print("Draining Tank...")
    end
  else
    clrScreen()
    print("Task: "..task)
    print("Waiting for items to melt...")
  end
end

os.loadApi("SmelteryAlloys")
while true do

  logic(SmelteryAlloys.alloys)
  os.sleep(25)
  
end