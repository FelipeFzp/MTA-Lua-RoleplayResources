local previewX, previewY, previewZ = 0, 0, 2000
local previewRot = 0
local previewVehicle;
local previewVehicleTimer;
local function handleOpenCarShopWindow(vehiclesToSell)
    -- WINDOW
    local scrWidth, scrHeight = guiGetScreenSize()
    local windowWidth, windowHeight = 500, 400
    local window = guiCreateWindow(scrWidth - windowWidth - 20, (scrHeight - windowHeight) / 2, windowWidth, windowHeight, "Loja de Carros e Motos", false)

    -- BUTTON
    addEventHandler("onClientGUIClick", 
    guiCreateButton(0.8, 0.9, 0.2, 0.08, "Voltar", true, window), function() 
        if(isElement(previewVehicle)) then destroyElement(previewVehicle) end
        if(isTimer(previewVehicleTimer)) then killTimer(previewVehicleTimer) end
        setCameraTarget(localPlayer)
        destroyElement(window)
        showCursor(false)
        setPlayerHudComponentVisible("all", true)
        setElementFrozen(localPlayer, false)
    end)

    -- LIST
    local carsList = guiCreateGridList(0.02, 0.08, 0.5, 0.9, true, window)
    guiGridListAddColumn(carsList, "Modelo", 0.5)
    guiGridListAddColumn(carsList, "Preço", 0.4)
    for i, vehicle in ipairs(vehiclesToSell) do
        local row = guiGridListAddRow(carsList)
        guiGridListSetItemText(carsList, row, 1, getVehicleNameFromModel(vehicle.modelId), false, false)
        guiGridListSetItemText(carsList, row, 2, "R$ "..vehicle.price..",00", false, false)
    end

    -- COLOR PICKER
    local r1, g1, b1, r2, g2, b2, r3, g3, b3 = 0, 0, 0, 255, 255, 255, 0, 0, 0
    guiCreateLabel(0.55, 0.08, 0.4, 0.04, "Vermelho", true, window)
    setElementID(guiCreateScrollBar(0.55, 0.14, 0.4, 0.05, true, true, window), "r")

    guiCreateLabel(0.55, 0.22, 0.4, 0.04, "Verde", true, window)
    setElementID(guiCreateScrollBar(0.55, 0.28, 0.4, 0.05, true, true, window), "g")

    guiCreateLabel(0.55, 0.37, 0.4, 0.04, "Azul", true, window)
    setElementID(guiCreateScrollBar(0.55, 0.43, 0.4, 0.05, true, true, window), "b")

    local color1Radio = guiCreateRadioButton(0.55, 0.50, 0.1, 0.05, "Cor 1", true, window)
    local color2Radio = guiCreateRadioButton(0.70, 0.50, 0.1, 0.05, "Cor 2", true, window)
    local color3Radio = guiCreateRadioButton(0.85, 0.50, 0.1, 0.05, "Cor 3", true, window)
    guiRadioButtonSetSelected(color1Radio, true)
    addEventHandler("onClientGUIClick", color1Radio, function() 
        guiScrollBarSetScrollPosition(getElementByID("r"), (r1 * 100) / 255)
        guiScrollBarSetScrollPosition(getElementByID("g"), (g1 * 100) / 255)
        guiScrollBarSetScrollPosition(getElementByID("b"), (b1 * 100) / 255)
    end, false)
    addEventHandler("onClientGUIClick", color2Radio, function() 
        guiScrollBarSetScrollPosition(getElementByID("r"), (r2 * 100) / 255)
        guiScrollBarSetScrollPosition(getElementByID("g"), (g2 * 100) / 255)
        guiScrollBarSetScrollPosition(getElementByID("b"), (b2 * 100) / 255)
    end, false)
    addEventHandler("onClientGUIClick", color3Radio, function() 
        guiScrollBarSetScrollPosition(getElementByID("r"), (r3 * 100) / 255)
        guiScrollBarSetScrollPosition(getElementByID("g"), (g3 * 100) / 255)
        guiScrollBarSetScrollPosition(getElementByID("b"), (b3 * 100) / 255)
    end, false)

    addEventHandler("onClientGUIScroll", window, function() 
        if(not isElement(previewVehicle)) then return end
        
        local elementId = getElementID(source)
        if(elementId == "r") then 
            if(guiRadioButtonGetSelected(color1Radio)) then r1 = (guiScrollBarGetScrollPosition(source) / 100) * 255 end
            if(guiRadioButtonGetSelected(color2Radio)) then r2 = (guiScrollBarGetScrollPosition(source) / 100) * 255 end
            if(guiRadioButtonGetSelected(color3Radio)) then r3 = (guiScrollBarGetScrollPosition(source) / 100) * 255 end
        end
        if(elementId == "g") then 
            if(guiRadioButtonGetSelected(color1Radio)) then g1 = (guiScrollBarGetScrollPosition(source) / 100) * 255 end
            if(guiRadioButtonGetSelected(color2Radio)) then g2 = (guiScrollBarGetScrollPosition(source) / 100) * 255 end
            if(guiRadioButtonGetSelected(color3Radio)) then g3 = (guiScrollBarGetScrollPosition(source) / 100) * 255 end
        end
        if(elementId == "b") then 
            if(guiRadioButtonGetSelected(color1Radio)) then b1 = (guiScrollBarGetScrollPosition(source) / 100) * 255 end
            if(guiRadioButtonGetSelected(color2Radio)) then b2 = (guiScrollBarGetScrollPosition(source) / 100) * 255 end
            if(guiRadioButtonGetSelected(color3Radio)) then b3 = (guiScrollBarGetScrollPosition(source) / 100) * 255 end
        end
        
        setVehicleColor(previewVehicle, r1, g1, b1, r2, g2, b2, r3, g3, b3, r3, g3, b3)
    end)
    

    -- LISTEN LIST ITEM CLICK
    addEventHandler("onClientGUIClick", carsList, function() 
        setElementFrozen(localPlayer, true)
        local row, col = guiGridListGetSelectedItem(carsList)
        local vehicle = vehiclesToSell[row + 1]
        if(vehicle == false or vehicle == nil) then return end

        if(isElement(previewVehicle)) then destroyElement(previewVehicle) end
        
        local vehicleXOffset = 3
        previewVehicle = createVehicle(vehicle.modelId, previewX + vehicleXOffset, previewY, previewZ, previewRot, 0, 0, "CAR SHOP")
        setVehicleColor(previewVehicle, r1, g1, b1, r2, g2, b2, r3, g3, b3, r3, g3, b3)
        setElementFrozen(previewVehicle, true)
        
        local cameraZoom = 10
        local cameraAngle = 180
        local rx, ry, rz = previewX+math.sin(math.rad(cameraAngle)) + cameraZoom, previewY+math.cos(math.rad(cameraAngle)) + cameraZoom, previewZ
        setCameraMatrix(rx, ry, rz, previewX, previewY, previewZ)
        
        if(isTimer(previewVehicleTimer)) then killTimer(previewVehicleTimer) end
        previewVehicleTimer = setTimer(function() 
            previewRot = previewRot + 1
            setElementRotation(previewVehicle, 0, 0, previewRot)
            if(previewRot > 360) then previewRot = 0 end
        end, 1, 0)
    end)

    guiWindowSetSizable(window, false)
    guiWindowSetMovable(window, false)
    setPlayerHudComponentVisible("all", false)
    guiSetVisible(window, true)
    showCursor(true)
end
addEvent("openCarShopWindow", true)
addEventHandler("openCarShopWindow", getRootElement(), handleOpenCarShopWindow)