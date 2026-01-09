# YouTube Automation Studio - Setup Guide

## Overview

YouTube Automation Studio is a comprehensive n8n-based system for automating faceless YouTube video creation. This guide will help you set up and configure all 13 workflows.

## Prerequisites

### Required Services

1. **n8n** (Self-hosted or Cloud)
   - Version 1.0+ recommended
   - PostgreSQL database connection

2. **API Keys Required**
   - OpenAI API Key (GPT-4o-mini or GPT-4o)
   - ElevenLabs API Key (Text-to-Speech)
   - Pexels API Key (Stock videos/photos)
   - Shotstack API Key (Video rendering)
   - YouTube Data API v3 Key
   - YouTube OAuth2 Credentials

3. **PostgreSQL Database**
   - Version 12+
   - Create a dedicated database for the studio

## Installation Steps

### Step 1: Database Setup

Run the `database-schema.sql` script to create all required tables:

```bash
psql -U your_user -d your_database -f database-schema.sql
```

This creates:
- `yt_studio_config` - Configuration storage
- `yt_studio_videos` - Video records and manifests
- `yt_studio_assets` - Asset tracking
- `yt_studio_audit_log` - Activity logging
- `yt_studio_trend_cache` - Trend data caching
- `yt_studio_shorts_extraction` - Shorts extraction results
- `yt_studio_voice_presets` - Voice configuration presets

### Step 2: n8n Environment Variables

Set these environment variables in your n8n instance:

```env
# API Keys
OPENAI_API_KEY=sk-...
ELEVENLABS_API_KEY=...
PEXELS_API_KEY=...
SHOTSTACK_API_KEY=...
SHOTSTACK_SANDBOX_KEY=...
YOUTUBE_API_KEY=...

# Database
DATABASE_URL=postgresql://user:pass@host:5432/dbname

# n8n Base URL (for inter-workflow calls)
N8N_BASE_URL=http://localhost:5678
```

### Step 3: Import Workflows

Import each workflow JSON file into n8n in this order:

1. `WF-10-config-manager.json` - Configuration system
2. `WF-00-main-router.json` - Entry point
3. `WF-01-orchestrator.json` - Pipeline coordinator
4. `WF-02-trend-analyzer.json` - Trend analysis
5. `WF-03-script-generator.json` - Script creation
6. `WF-04-script-reviewer.json` - Script validation
7. `WF-05-voiceover.json` - TTS generation
8. `WF-06-asset-collector.json` - Asset gathering
9. `WF-07-video-renderer.json` - Video rendering
10. `WF-08-thumbnail.json` - Thumbnail generation
11. `WF-09-youtube-publisher.json` - YouTube upload
12. `WF-11-settings-panel.json` - Settings form
13. `WF-12-short-extractor.json` - Shorts extraction

### Step 4: Configure Credentials

In n8n, create these credentials:

1. **PostgreSQL YT Studio**
   - Host, Port, Database, User, Password
   - Name: `PostgreSQL YT Studio`

2. **YouTube OAuth2**
   - Client ID, Client Secret
   - Scopes: `https://www.googleapis.com/auth/youtube.upload`
   - Name: `YouTube OAuth2`

### Step 5: Activate Workflows

After importing, activate these workflows:
- WF-00 Main Router
- WF-11 Settings Panel

Other workflows are called via HTTP and don't need to be active.

## Usage

### Test Mode

Start with test mode to verify the pipeline without costs:

```json
POST /webhook/main-router
{
  "mode": "test",
  "category": "education",
  "custom_topic": "5 Study Tips for Better Memory",
  "language": "en"
}
```

Test mode:
- Creates 30-second preview videos
- Uses Shotstack Sandbox API (free)
- Skips YouTube upload
- Returns pipeline status

### Production Mode - Auto Trend

Let AI find trending topics:

```json
POST /webhook/main-router
{
  "mode": "auto_trend",
  "category": "tech_ai",
  "language": "en",
  "target_countries": ["US", "UK"],
  "video_length": {
    "normal": "medium_8_12"
  }
}
```

### Production Mode - Manual Topic

Specify your own topic:

```json
POST /webhook/main-router
{
  "mode": "manual",
  "category": "finance",
  "custom_topic": "How to Build Passive Income in 2024",
  "language": "en"
}
```

### Extract Shorts from Long Video

Create YouTube Shorts from existing videos:

```json
POST /webhook/main-router
{
  "mode": "auto_trend",
  "video_type": "short_from_long",
  "source_video_url": "https://youtube.com/watch?v=VIDEO_ID"
}
```

## Workflow Architecture

```
[Main Router WF-00]
        |
        v
[Config Manager WF-10] --> [Database]
        |
        v
[Orchestrator WF-01]
        |
        +---> [Trend Analyzer WF-02] (if auto_trend)
        +---> [Short Extractor WF-12] (if short_from_long)
        |
        v
[Script Generator WF-03]
        |
        v
[Script Reviewer WF-04]
        |
        v
[Voiceover Generator WF-05]
        |
        v
[Asset Collector WF-06]
        |
        v
[Video Renderer WF-07]
        |
        v
[Thumbnail Generator WF-08]
        |
        v
[YouTube Publisher WF-09]
```

## Supported Categories

- `tech_ai` - Technology & AI
- `finance` - Finance & Investing
- `health` - Health & Fitness
- `education` - Education & Learning
- `gaming` - Gaming
- `cooking` - Cooking & Recipes
- `travel` - Travel
- `real_estate` - Real Estate
- `reviews` - Product Reviews
- `pets` - Pets & Animals
- `custom` - Custom topic (requires `custom_topic`)

## Supported Languages

- `en` - English
- `ar` - Arabic
- `tr` - Turkish
- `es` - Spanish
- `fr` - French
- `de` - German
- `pt` - Portuguese
- `hi` - Hindi

## Video Length Presets

- `short_3_5` - 3-5 minutes (~750 words)
- `medium_8_12` - 8-12 minutes (~2000 words)
- `long_15_20` - 15-20 minutes (~4000 words)
- `extra_25_40` - 25-40 minutes (~7500 words)

## Troubleshooting

### Common Issues

1. **Workflow not found**
   - Ensure N8N_BASE_URL is set correctly
   - Check that workflows are imported and active

2. **Database connection failed**
   - Verify PostgreSQL credentials
   - Check network connectivity

3. **API rate limits**
   - Workflows have built-in retry logic
   - Consider adding delays between runs

4. **Video rendering timeout**
   - Shotstack has 5-minute timeout for sandbox
   - Long videos may need production API

### Logs

Check n8n execution history for detailed logs. Each workflow logs:
- Input validation errors
- API response status
- Pipeline progress

## Cost Estimation

Per video (approximate):
- OpenAI GPT-4o-mini: $0.02-0.10
- ElevenLabs TTS: $0.05-0.30 (based on text length)
- DALL-E 3 Images: $0.04-0.12
- Shotstack Rendering: $0.10-0.50

Test mode: ~$0.02 (uses sandbox APIs)
Production 8-12 min video: ~$0.50-1.00

## Support

For issues and feature requests, check the documentation or contact support.
