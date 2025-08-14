onOutput = async(function(triggerId)
    -- 이미지 생성에 필요한 변수들을 가져옵니다.
    local imgtag = getChatVar(triggerId, "imgtag")
    local basetag = "score_9, score_8_up, score_7_up, realistic, real, (natural huge breasts:1.6), 1girl, korean idol, <lora:Expressive_H:1.2>, <lora:natural_breasts_v1:1.4>, <lora:JangWonyoung_SDXL:1.05>, JANG_ICE"
    -- 네거티브 프롬프트용 'negtag' 변수를 가져옵니다.
    local negtag = "blurry, lowres, error, film grain, scan artifacts, worst quality, bad quality, jpeg artifacts, very displeasing, chromatic aberration, multiple views, logo, too many watermarks, white blank page, blank page, normal quality, bad quality, low quality, worst quality, lowres, displeasing, very displeasing, bad, bad anatomy, bad hands, text, error, missing, missing finger, extra, extra digits, extra breasts, extra amd, fewer, fewer digits, cropped, JPEG artifacts, signature, watermark, username, blurry, artist name, bad face, bad eyes, bad breasts, bad nipples, fat, duplicate, mutation, deformed, disfigured, extra arms, extra legs, long neck, bad feet, bad proportions, extra, fewer, unfinished, chromatic aberration, scan, scan artifacts, pubic hair, loli, pubic hair"

    -- imgtag 변수에 내용이 있을 경우에만 이미지 생성을 시도합니다.
    if imgtag and imgtag ~= "" then
        local final_prompt = imgtag
        if basetag and basetag ~= "" then
            final_prompt = basetag .. ", " .. imgtag
        end

        -- WebUI용 파라미터 설정 (webui_fetch_success.js 참조)
        local params = {
            prompt = final_prompt,
            negative_prompt = negtag,
            sampler_name = "DPM++ 2M SDE",
            scheduler = "Align Your Steps",
            steps = 20,
            width = 768,
            height = 768,
            cfg_scale = 5
        }

        -- pcall을 사용해 generateImageSD 함수를 안전하게 호출합니다.
        -- :await()는 이미지 생성이 완료될 때까지 코드 실행을 기다립니다.
        local imageResult
        local success, result = pcall(function()
            -- generateImageSD에 triggerId와 파라미터 객체를 전달합니다.
            imageResult = generateImageSD(triggerId, params):await()
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

    -- Process chat messages (keeping the original formatting logic)
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
            local time = os.date("%H:%M")  -- Current time (HH:MM format)
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

-- Edit input listener for outgoing messages
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
            local time = os.date("%H:%M")  -- Current time (HH:MM format)
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

-- Edit input listener for timestamp addition
listenEdit("editInput", function(triggerId, data)
    local now = os.date("*t")
    local lines = {}
    for line in data:gmatch("[^\r\n]+") do
        table.insert(lines, "%"..line)
    end
    local newData = table.concat(lines, "\n").."["..getCurrentTime(now).."]"
    return newData
end)

-- Helper function for time formatting
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