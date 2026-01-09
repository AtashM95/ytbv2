# YouTube Automation Studio - API Documentation

## Base URL

```
http://your-n8n-instance:5678/webhook
```

## Main Endpoints

### POST /main-router

Main entry point for all video creation requests.

#### Request Body

```json
{
  "mode": "test | auto_trend | manual",
  "video_type": "normal | short | both | short_from_long",
  "category": "tech_ai | finance | health | education | gaming | cooking | travel | real_estate | reviews | pets | custom",
  "custom_topic": "Your specific topic (required for manual mode or custom category)",
  "language": "en | ar | tr | es | fr | de | pt | hi",
  "target_countries": ["US", "UK", "CA", "AU"],
  "video_length": {
    "normal": "short_3_5 | medium_8_12 | long_15_20 | extra_25_40",
    "short": "60s"
  },
  "quality": {
    "video": "720p | 1080p | 4k",
    "voice": "standard | premium"
  },
  "options": {
    "auto_thumbnail": true,
    "seo_optimization": true,
    "auto_tags": true,
    "best_time_publish": false,
    "ab_thumbnail_test": false,
    "competitor_analysis": false
  },
  "source_video_url": "https://youtube.com/watch?v=... (for short_from_long)"
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "status": "COMPLETED | FAILED | TEST_COMPLETE",
  "mode": "test",
  "video_type": "normal",
  "youtube_video_id": "VIDEO_ID",
  "youtube_url": "https://youtube.com/watch?v=VIDEO_ID",
  "thumbnail_url": "https://...",
  "render_url": "https://...",
  "test_result": {
    "pipeline_status": {...},
    "preview_url": "https://...",
    "estimated_production_cost": "$0.50",
    "estimated_production_time": "8 minutes"
  },
  "topic": "Selected topic",
  "category": "education",
  "language": "en",
  "started_at": "2024-01-01T00:00:00Z",
  "completed_at": "2024-01-01T00:10:00Z",
  "errors": [],
  "warnings": []
}
```

---

### POST /wf-02-trend

Analyze trending topics for a category.

#### Request Body

```json
{
  "run_id": "run_uuid",
  "category": "tech_ai",
  "language": "en",
  "target_countries": ["US"]
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "mode": "auto_trend",
  "category": "tech_ai",
  "language": "en",
  "selected_topic": "How AI is Changing Healthcare",
  "keywords": ["AI", "healthcare", "technology", "2024"],
  "estimated_cpm": 18.5,
  "competition_level": "medium",
  "trending_score": 85,
  "trend_analysis": {
    "trending_videos": [...],
    "extracted_topics": [...],
    "ai_reasoning": "This topic combines..."
  },
  "analyzed_at": "2024-01-01T00:00:00Z",
  "status": "TREND_ANALYZED"
}
```

---

### POST /wf-03-script

Generate video script.

#### Request Body

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "selected_topic": "5 Tips for Better Sleep",
  "keywords": ["sleep", "health", "tips"],
  "language": "en",
  "video_type": "normal",
  "category": "health",
  "resolved_config": {...},
  "computed": {
    "target_duration_sec": 600,
    "target_word_count": 1500
  }
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "script_draft": "[SCENE 1: ...] ...",
  "scene_plan": [
    {
      "scene": 1,
      "description": "Introduction",
      "duration_sec": 30
    }
  ],
  "word_count": 1523,
  "target_words": 1500,
  "is_short": false,
  "status": "SCRIPT_GENERATED"
}
```

---

### POST /wf-04-review

Review and enhance script with metadata.

#### Request Body

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "manifest": {
    "script": {
      "draft": "[SCENE 1: ...] ..."
    }
  },
  "selected_topic": "5 Tips for Better Sleep",
  "keywords": ["sleep", "health"],
  "language": "en"
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "script_approved": "[SCENE 1: ...] ...",
  "review_passed": true,
  "issues": [],
  "metadata": {
    "title": "5 Simple Tips for Better Sleep Tonight",
    "description": "Discover proven techniques...",
    "tags": ["sleep tips", "better sleep", "health"],
    "category_id": "26"
  },
  "reviewed_at": "2024-01-01T00:00:00Z",
  "status": "SCRIPT_REVIEWED"
}
```

---

### POST /wf-05-voice

Generate voiceover audio.

#### Request Body

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "manifest": {
    "script": {
      "approved": "Your script text here..."
    }
  },
  "language": "en",
  "resolved_config": {...},
  "computed": {
    "voice_id": "pNInz6obpgDQGcFmaJgB"
  }
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "voiceover_url": "https://storage.../voiceover/run_uuid.mp3",
  "voice_id": "pNInz6obpgDQGcFmaJgB",
  "text_length": 1500,
  "has_audio": true,
  "generated_at": "2024-01-01T00:00:00Z",
  "status": "VOICEOVER_GENERATED"
}
```

---

### POST /wf-06-assets

Collect visual assets for video.

#### Request Body

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "manifest": {
    "scene_plan": [
      {
        "scene": 1,
        "description": "Person sleeping peacefully",
        "duration_sec": 30
      }
    ]
  },
  "resolved_config": {...}
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "assets": [
    {
      "scene": 1,
      "description": "Person sleeping peacefully",
      "asset_type": "pexels_video",
      "asset_url": "https://...",
      "duration_needed": 30,
      "source": "pexels_video",
      "fallback_used": null
    }
  ],
  "asset_summary": {
    "total": 5,
    "successful": 5,
    "failed": 0,
    "sources": {
      "pexels_video": 3,
      "pexels_photo": 1,
      "dalle": 1
    }
  },
  "collected_at": "2024-01-01T00:00:00Z",
  "status": "ASSETS_COLLECTED"
}
```

---

### POST /wf-07-render

Render video using Shotstack.

#### Request Body

```json
{
  "run_id": "run_uuid",
  "mode": "test",
  "manifest": {
    "assets": [...],
    "voiceover_url": "https://..."
  },
  "resolved_config": {...},
  "computed": {
    "target_duration_sec": 30
  },
  "quality": {
    "video": "1080p"
  }
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "mode": "test",
  "render_url": "https://cdn.shotstack.io/...",
  "render_id": "render_uuid",
  "render_status": "completed",
  "is_test": true,
  "rendered_at": "2024-01-01T00:00:00Z",
  "status": "VIDEO_RENDERED"
}
```

---

### POST /wf-08-thumbnail

Generate thumbnail image.

#### Request Body

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "selected_topic": "5 Tips for Better Sleep",
  "category": "health",
  "manifest": {
    "metadata": {
      "title": "5 Simple Tips for Better Sleep Tonight",
      "tags": ["sleep", "health"]
    }
  },
  "resolved_config": {...}
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "thumbnail_url": "https://oaidalleapi.../...",
  "thumbnail_permanent_url": "https://storage.../thumbnails/run_uuid.png",
  "revised_prompt": "...",
  "title_for_overlay": "5 Simple Tips for Better Sleep Tonight",
  "generated_at": "2024-01-01T00:00:00Z",
  "status": "THUMBNAIL_GENERATED"
}
```

---

### POST /wf-09-publish

Upload video to YouTube.

#### Request Body

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "manifest": {
    "render_url": "https://cdn.shotstack.io/...",
    "thumbnail_url": "https://...",
    "metadata": {
      "title": "5 Simple Tips for Better Sleep Tonight",
      "description": "...",
      "tags": ["sleep", "health"],
      "category_id": "26"
    }
  },
  "language": "en",
  "options": {
    "best_time_publish": false
  },
  "resolved_config": {...}
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "youtube_video_id": "dQw4w9WgXcQ",
  "youtube_url": "https://youtube.com/watch?v=dQw4w9WgXcQ",
  "privacy_status": "public",
  "scheduled_publish": null,
  "thumbnail_set": true,
  "completed_at": "2024-01-01T00:00:00Z",
  "status": "PUBLISHED"
}
```

---

### POST /wf-10-config

Load configuration settings.

#### Request Body

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "video_type": "normal",
  "language": "en"
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "mode": "manual",
  "resolved_config": {
    "openai": {...},
    "tts": {...},
    "video": {...},
    "storage": {...}
  },
  "computed": {
    "target_duration_sec": 600,
    "target_word_count": 1500,
    "voice_id": "..."
  },
  "config_loaded_at": "2024-01-01T00:00:00Z"
}
```

---

### POST /wf-12-short-extractor

Extract shorts segments from existing video.

#### Request Body

```json
{
  "run_id": "run_uuid",
  "mode": "auto_trend",
  "source_video_url": "https://youtube.com/watch?v=VIDEO_ID"
}
```

#### Response

```json
{
  "run_id": "run_uuid",
  "mode": "auto_trend",
  "source_video": {
    "id": "VIDEO_ID",
    "title": "Original Video Title",
    "duration": 1200
  },
  "extraction_jobs": [
    {
      "segment_id": "seg_1",
      "source_url": "https://youtube.com/watch?v=VIDEO_ID",
      "start_time": 120,
      "end_time": 175,
      "duration": 55,
      "suggested_title": "The Shocking Truth About...",
      "viral_score": 85,
      "create_request": {...}
    }
  ],
  "total_shorts_to_create": 3,
  "completed_at": "2024-01-01T00:00:00Z",
  "status": "EXTRACTION_READY"
}
```

---

### GET /wf-11-settings

Access the settings form (browser-based).

Opens a form interface for configuring:
- Channel category
- Primary language
- Target countries
- Video length defaults
- Quality settings
- Voice preferences
- API configurations

---

## Error Responses

All endpoints return errors in this format:

```json
{
  "run_id": "run_uuid",
  "error": true,
  "error_code": "VALIDATION_ERROR | API_ERROR | TIMEOUT_ERROR",
  "error_message": "Detailed error description",
  "status": "FAILED"
}
```

## Status Codes

| Status | Description |
|--------|-------------|
| `PENDING` | Request received, not yet processed |
| `TREND_ANALYZED` | Trend analysis complete |
| `SCRIPT_GENERATED` | Script created |
| `SCRIPT_REVIEWED` | Script validated and metadata added |
| `VOICEOVER_GENERATED` | Audio created |
| `ASSETS_COLLECTED` | Visual assets gathered |
| `VIDEO_RENDERED` | Video rendering complete |
| `THUMBNAIL_GENERATED` | Thumbnail created |
| `PUBLISHED` | Video uploaded to YouTube |
| `TEST_COMPLETE` | Test run finished (no upload) |
| `FAILED` | Error occurred |

## Rate Limits

- OpenAI: 3 requests/minute (built-in)
- ElevenLabs: Varies by plan
- Pexels: 200 requests/hour
- Shotstack: 100 renders/hour (production)
- YouTube API: 10,000 units/day

All workflows include retry logic with exponential backoff.
