const API_URL = 'http://127.0.0.1:7860/sdapi/v1/txt2img';

const payload = {
    "prompt": "score_9, score_8_up, score_7_up, realistic, real, (natural huge breasts:1.1), 1girl, korean idol, <lora:Expressive_H:1.2>, <lora:natural_breasts_v1:1.4>,",
    "negative_prompt": "blurry, lowres, error, film grain, scan artifacts, worst quality, bad quality, jpeg artifacts, very displeasing, chromatic aberration, multiple views, logo, too many watermarks, white blank page, blank page, normal quality, bad quality, low quality, worst quality, lowres, displeasing, very displeasing, bad, bad anatomy, bad hands, text, error, missing, missing finger, extra, extra digits, extra breasts, extra amd, fewer, fewer digits, cropped, JPEG artifacts, signature, watermark, username, blurry, artist name, bad face, bad eyes, bad breasts, bad nipples, fat, duplicate, mutation, deformed, disfigured, extra arms, extra legs, long neck, bad feet, bad proportions, extra, fewer, unfinished, chromatic aberration, scan, scan artifacts, pubic hair, loli, pubic hair",
    "sampler_name": "DPM++ 2M SDE",
    "scheduler": "Align Your Steps",
    "steps": 20,
    "width": 768,
    "height": 768,
    "cfg_scale": 5,
  
    "alwayson_scripts": {
      "ADetailer": {
        "args": [
          true,
          false,
          {
            "ad_model": "face_yolov8n.pt",
            "ad_model_classes": "",
            "ad_prompt": "photo realistic, highres, high quality, <lora:JangWonyoung_SDXL:1.05>, JANG_ICE",
            "ad_negative_prompt": "artifact, blur",
            "ad_confidence": 0.3,
            "ad_mask_filter_method": "Area",
            "ad_mask_k": 0,
            "ad_mask_min_ratio": 0.0,
            "ad_mask_max_ratio": 1.0,
            "ad_dilate_erode": 4,
            "ad_x_offset": 0,
            "ad_y_offset": 0,
            "ad_mask_merge_invert": "None",
            "ad_mask_blur": 4,
  
            "ad_denoising_strength": 0.45,          // inpaint denoise
            "ad_inpaint_only_masked": true,
            "ad_inpaint_only_masked_padding": 32,
  
            "ad_use_inpaint_width_height": false,
            "ad_inpaint_width": 512,
            "ad_inpaint_height": 512,
  
            "ad_use_steps": false,
            "ad_steps": 10,
            "ad_use_cfg_scale": false,
            "ad_cfg_scale": 5.0,
            "ad_use_checkpoint": false,
            "ad_checkpoint": null,
            "ad_use_vae": false,
            "ad_vae": null,
            "ad_use_sampler": false,
  
            "ad_use_noise_multiplier": false,
            "ad_noise_multiplier": 1.0,
            "ad_use_clip_skip": false,
            "ad_clip_skip": 1,
            "ad_restore_face": false,
  
            "ad_controlnet_model": "None",
            "ad_controlnet_module": "None",
            "ad_controlnet_weight": 1.0,
            "ad_controlnet_guidance_start": 0.0,
            "ad_controlnet_guidance_end": 1.0
          }
        ]
      }
    }
  }
  ;

fetch(API_URL, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(payload)
})
  .then(res => res.json())
  .then(data => {
    const img = document.createElement('img');
    img.src = `data:image/png;base64,${data.images[0]}`;
    document.body.appendChild(img);
  })
  .catch(err => console.error(err));
