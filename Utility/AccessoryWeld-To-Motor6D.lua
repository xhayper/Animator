local AccessoryList = {}

for _,i in next, path.to.Character:GetChildren() do
    if not i:IsA("Accessory") or not table.find(AccessoryList, i.Name) then continue end
    i.Handle.Name = i.Name
    local Motor = Instance.new("Motor6D", i[i.Name])
    Motor.Name = i.Name
    Motor.Part0 = i[i.Name].AccessoryWeld.Part1
    Motor.Part1 = i[i.Name].AccessoryWeld.Part0
    Motor.C0 = i[i.Name].AccessoryWeld.C0:Inverse()
    Motor.C1 = i[i.Name].AccessoryWeld.C1:Inverse()
    i[i.Name].AccessoryWeld:Destroy()
end