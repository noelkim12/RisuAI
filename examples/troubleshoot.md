## 응답을 “완료 시점”으로 보장하고 싶으면(선택)

* 생성 호출 후 **/progress 폴링**으로 완료를 확인하고 처리해.

  * `GET /sdapi/v1/progress?skip_current_image=true`
  * `state.job_count == 0` 또는 `progress >= 1.0`이면 끝난 것. ([GitHub][3], [Reddit][4])

---

## 체크리스트(정리)

* [ ] 응답 타이밍 의심되면 `/progress` 폴링으로 “완료 이후 처리” 보장. ([GitHub][3], [Reddit][4])

이렇게 바꾸면 400/조기응답/무의미한 옵션 문제를 한 번에 줄일 수 있어.

[3]: https://github.com/AUTOMATIC1111/stable-diffusion-webui/blob/master/modules/api/api.py?utm_source=chatgpt.com "api.py - AUTOMATIC1111/stable-diffusion-webui"
[4]: https://www.reddit.com/r/StableDiffusion/comments/xxfx1b/anyone_using_the_stablediffusionwebui_repo_by/?utm_source=chatgpt.com "Anyone using the stable-diffusion-webui repo by ..."
