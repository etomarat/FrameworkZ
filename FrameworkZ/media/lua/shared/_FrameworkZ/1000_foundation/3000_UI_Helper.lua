FrameworkZ = FrameworkZ or {}

FrameworkZ.UI = {}

function FrameworkZ.UI.GetCenteredX(length, fontSize, text)
    local width = getTextManager():MeasureStringX(fontSize, text)

    return (length / 2) - (width / 2)
end

function FrameworkZ.UI.GetMiddle(length, fontSize, text)
    local width = getTextManager():MeasureStringX(fontSize, text)

    return (length - width) / 2
end

function FrameworkZ.UI.GetHeight(fontSize, text)
    local height = getTextManager():MeasureStringY(fontSize, text)

    return height
end
