onOutput = async(function(triggerId)
    -- 이미지 생성에 필요한 변수들을 가져옵니다.
    local imgtag = getChatVar(triggerId, "imgtag")
    local basetag = "2.4::artist: sano yuuto::, 1.2::artist: sangsoo_jeong::, artist: sweetonedollar, 1.3::artist: meolkyy::, 0.8::artist: seapall::, artist: hoo_bamon, 1.4::artist: flamma_(immortalemignis),:: , artist: Wengwengchim, 1.2::artist: hiramedousa::, artist: zipcy, artist: devilzong, artist: zero_q_0q, artist: liu2e3ing, 2::artist: nagamerin::, 1.2::artist: solipsist:: artist: j._won_han, 2::best quality, very aesthetic, best details, highres,amazing quality,photorealistic, skin definition, detailed, intricate details, Volumetric lighting, Cinematic lighting, hyper detailed skin, Lustrous skin, k-pop ::,2.5::depth of field, year 2024, year 2025,best quality, amazing quality, very aesthetic, absurdres::, 0.8::makeup::, -10::artist collaboration::, detailed background, very aesthetic, masterpiece, no text, 1girl, 1.7::huge breasts::, black long hair, black eyes"
    -- 네거티브 프롬프트용 'negtag' 변수를 가져옵니다. 없으면 빈 문자열을 사용합니다.
    local negtag = "lowres, {bad}, error, fewer, extra, missing, worst quality, jpeg artifacts, bad quality, watermark, unfinished, displeasing, chromatic aberration, signature, extra digits, artistic error, username, scan, [abstract], multiple views, lowres, jpeg artifacts, worst quality, watermark, blurry, very displeasing, bad face, bad feet, bad anatomy, bad proportions, extra arms, extra legs, multiple legs, artistic error, aesthetic, text, extra digits, fewer digits, cropped, JPEG artifacts, signature, watermark, username, artist name, unfinished, scan, scan artifacts, {{{blurry}}}, chromatic aberration, forehead mark, {{red skin}}, 4::bad hand, bad anatomy, mosaic, ::, 5::multiple views, ::, 3::three quarter view, ::, 2::object, sketch, nail art, text::, lowres, aliasing, makeup, eyeliner, eyeshadow, lipstick"

    -- imgtag 변수에 내용이 있을 경우에만 이미지 생성을 시도합니다.
    if imgtag and imgtag ~= "" then
        local final_prompt = imgtag
        if basetag and basetag ~= "" then
            final_prompt = basetag .. ", " .. imgtag
        end

        -- pcall을 사용해 generateImage 함수를 안전하게 호출합니다.
        -- :await()는 이미지 생성이 완료될 때까지 코드 실행을 기다립니다.
        local imageResult
        local success, result = pcall(function()
            -- generateImage에 triggerId, 최종 프롬프트, 네거티브 프롬프트를 전달합니다.
            imageResult = generateImage(triggerId, final_prompt, negtag):await()
        end)

        if success and imageResult then
            -- 성공 시, 반환된 에셋 문자열을 'imgurl' 변수에 저장합니다.
            setChatVar(triggerId, "imgurl", imageResult)
            setChatVar(triggerId, "imgtag", "")
        else
            -- 실패 시, 에러 메시지를 'imgurl' 변수에 저장합니다.
            setChatVar(triggerId, "imgurl", "Image generation failed: " .. tostring(result))
            setChatVar(triggerId, "imgtag", "")
            return nil
        end
    end
    local chat = getFullChat(triggerId)
	local lastIndex = #chat
    local lastMessage = chat[#chat]
    local original = lastMessage.data
    local messages = {}
	original = string.gsub(original, "\n", " ")
	original = string.gsub(original, "```.-```", "")
	
    for content in original:gmatch("⟨(.-)⟩") do
        table.insert(messages, content)
    end

    local wrapped_messages = {}

    for i, msg in ipairs(messages) do
        if i == #messages then
            local time = os.date("%H:%M")  -- 현재 시간 (HH:MM 형식)
            table.insert(wrapped_messages, string.format(
                '<div class="message">%s<span class="time">%s</span></div>', msg, time))
        else
            table.insert(wrapped_messages, string.format('<div class="message">%s</div>', msg))
        end
    end

    local header = [[
<div class="chat">
   <div class="message-group incoming">
      <div class="avatar">
         <img src="{{source::char}}" alt="{{char}} profile" />
         <div class="username">{{char}}</div>
      </div>
      <div class="messages">
]]

    local footer = [[
      </div>
   </div>
</div>]]

    local final = header .. table.concat(wrapped_messages, "\n") .. footer .. [[<original>]] .. original .. [[</original>]]
    local final = string.gsub(final, "\n", " ")
    setChat(triggerId, lastIndex - 1, final)
end)


listenEdit("editInput", function(triggerId, data)
	local original = data
    local messages = {}
    for line in original:gmatch("[^\r\n]+") do
        table.insert(messages, line)
    end

    local wrapped_messages = {}
    local bracketed_messages = {}

    for i, msg in ipairs(messages) do
        table.insert(bracketed_messages, string.format("⟨%s⟩", msg))
        if i == #messages then
            local time = os.date("%H:%M")  -- 현재 시간 (HH:MM 형식)
            table.insert(wrapped_messages, string.format(
                '<div class="message">%s<span class="time">%s</span></div>', msg, time))
        else
            table.insert(wrapped_messages, string.format('<div class="message">%s</div>', msg))
        end
    end

    local header = [[
<div class="chat">
         <div class="message-group outgoing">
            <div class="messages">
]]

    local footer = [[
      </div>
   </div>
</div>
]]
    local bracket_output = table.concat(bracketed_messages, "\n")
    local final = header .. table.concat(wrapped_messages, "\n") .. footer .. [[<original>]] .. bracket_output .. [[</original>]]
    local final = string.gsub(final, "\n", " ")
    return final
end)

listenEdit("editInput", function(triggerId, data)
    local now = os.date("*t")
    local lines = {}
    for line in data:gmatch("[^\r\n]+") do
        table.insert(lines, "%%"..line)
    end
    local newData = table.concat(lines, "\n").."["..getCurrentTime(now).."]"
    return newData
end)

function getCurrentTime(now)
    now = now or os.date("*t")
    local year = now.year
    local month = string.format("%02d", now.month)
    local day = string.format("%02d", now.day)
    local dayOfWeek = os.date("%a", os.time(now))
    local hours = now.hour % 12 == 0 and 12 or now.hour % 12
    local minutes = string.format("%02d", now.min)
    local ampm = now.hour >= 12 and 'PM' or 'AM'
    local formattedTime = string.format("%d:%s %s", hours, minutes, ampm)
    
    local formattedDate = string.format("%d-%s-%s | %s | %s", year, month, day, dayOfWeek, formattedTime)
    return formattedDate
end