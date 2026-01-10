-- YouTube Automation Studio Database Schema
-- Version: 2.0
-- PostgreSQL 15+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- CONFIGURATION TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS yt_studio_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(255) NOT NULL,
    value TEXT,
    value_type VARCHAR(50) NOT NULL DEFAULT 'string',
    credential_ref VARCHAR(255),
    env_ref VARCHAR(255),
    scope VARCHAR(50) NOT NULL DEFAULT 'global',
    environment VARCHAR(50) NOT NULL DEFAULT 'production',
    channel_key VARCHAR(100),
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_by VARCHAR(100),

    CONSTRAINT yt_config_unique UNIQUE (environment, scope, channel_key, key)
);

CREATE INDEX idx_config_env ON yt_studio_config(environment);
CREATE INDEX idx_config_scope ON yt_studio_config(scope);
CREATE INDEX idx_config_channel_key ON yt_studio_config(channel_key);
CREATE INDEX idx_config_active ON yt_studio_config(is_active);
CREATE INDEX idx_config_key ON yt_studio_config(key);

-- =====================================================
-- VIDEOS TABLE (Main video records)
-- =====================================================
CREATE TABLE IF NOT EXISTS yt_studio_videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    run_id VARCHAR(255) UNIQUE NOT NULL,

    -- Request info
    mode VARCHAR(50) NOT NULL DEFAULT 'test',  -- test, auto_trend, manual
    video_type VARCHAR(50) NOT NULL DEFAULT 'normal',  -- normal, short, both, short_from_long
    category VARCHAR(100),
    custom_topic TEXT,
    language VARCHAR(10) DEFAULT 'en',
    target_countries TEXT[],  -- Array of country codes

    -- Quality settings
    video_quality VARCHAR(20) DEFAULT '1080p',
    voice_quality VARCHAR(20) DEFAULT 'premium',
    video_length_target VARCHAR(50),

    -- Content
    topic TEXT,
    keywords TEXT[],
    script_draft TEXT,
    script_approved TEXT,

    -- Generated content URLs
    voiceover_url TEXT,
    thumbnail_url TEXT,
    render_url TEXT,

    -- YouTube info
    youtube_video_id VARCHAR(100),
    youtube_url TEXT,
    youtube_title TEXT,
    youtube_description TEXT,
    youtube_tags TEXT[],
    privacy_status VARCHAR(50) DEFAULT 'private',
    scheduled_publish_at TIMESTAMP WITH TIME ZONE,

    -- Trend analysis
    trending_score INTEGER,
    estimated_cpm DECIMAL(10,2),
    competition_level VARCHAR(50),

    -- Status tracking
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    current_workflow VARCHAR(50),
    error_message TEXT,

    -- Analytics
    views INTEGER DEFAULT 0,
    likes INTEGER DEFAULT 0,
    comments INTEGER DEFAULT 0,
    estimated_revenue DECIMAL(10,2) DEFAULT 0,

    -- Full manifest (JSONB for flexibility)
    manifest JSONB,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    published_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_videos_run_id ON yt_studio_videos(run_id);
CREATE INDEX idx_videos_status ON yt_studio_videos(status);
CREATE INDEX idx_videos_mode ON yt_studio_videos(mode);
CREATE INDEX idx_videos_category ON yt_studio_videos(category);
CREATE INDEX idx_videos_created ON yt_studio_videos(created_at DESC);
CREATE INDEX idx_videos_youtube_id ON yt_studio_videos(youtube_video_id);

-- =====================================================
-- ASSETS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS yt_studio_assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    run_id VARCHAR(255) NOT NULL REFERENCES yt_studio_videos(run_id) ON DELETE CASCADE,
    asset_id VARCHAR(255) NOT NULL,

    -- Asset info
    type VARCHAR(50) NOT NULL,  -- video, image, audio
    source VARCHAR(50) NOT NULL,  -- pexels_video, pexels_photo, dalle_generated, elevenlabs
    scene_index INTEGER,

    -- URLs
    source_url TEXT,
    local_path TEXT,
    cdn_url TEXT,

    -- Metadata
    duration_sec DECIMAL(10,2),
    resolution VARCHAR(50),
    file_size_bytes BIGINT,
    mime_type VARCHAR(100),
    license VARCHAR(100),

    -- Source-specific metadata
    pexels_id VARCHAR(100),
    photographer VARCHAR(255),
    dalle_prompt TEXT,

    -- Additional metadata as JSONB
    metadata JSONB,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_assets_run_id ON yt_studio_assets(run_id);
CREATE INDEX idx_assets_type ON yt_studio_assets(type);
CREATE INDEX idx_assets_source ON yt_studio_assets(source);

-- =====================================================
-- AUDIT LOG TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS yt_studio_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    run_id VARCHAR(255) REFERENCES yt_studio_videos(run_id) ON DELETE SET NULL,
    workflow VARCHAR(50) NOT NULL,
    action VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    details JSONB,
    error_message TEXT,
    duration_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_audit_run_id ON yt_studio_audit_log(run_id);
CREATE INDEX idx_audit_workflow ON yt_studio_audit_log(workflow);
CREATE INDEX idx_audit_created ON yt_studio_audit_log(created_at DESC);

-- =====================================================
-- RUN REGISTRY TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS yt_run_registry (
    run_id VARCHAR(255) PRIMARY KEY,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    finished_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) NOT NULL,
    mode VARCHAR(50) NOT NULL DEFAULT 'test',
    environment VARCHAR(50) NOT NULL DEFAULT 'production',
    scope VARCHAR(50) NOT NULL DEFAULT 'global',
    channel_key VARCHAR(100),
    error_code VARCHAR(100),
    error_message TEXT,
    manifest_json JSONB
);

CREATE INDEX idx_run_registry_status ON yt_run_registry(status);
CREATE INDEX idx_run_registry_started_at ON yt_run_registry(started_at DESC);

-- =====================================================
-- TREND CACHE TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS yt_studio_trend_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category VARCHAR(100) NOT NULL,
    language VARCHAR(10) NOT NULL,
    region VARCHAR(10),

    -- Trend data
    topic TEXT NOT NULL,
    keywords TEXT[],
    trending_score INTEGER,
    search_volume INTEGER,
    competition_level VARCHAR(50),
    estimated_cpm DECIMAL(10,2),

    -- Similar videos
    similar_videos JSONB,

    -- Cache management
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() + INTERVAL '6 hours',
    is_used BOOLEAN DEFAULT false
);

CREATE INDEX idx_trend_category ON yt_studio_trend_cache(category);
CREATE INDEX idx_trend_language ON yt_studio_trend_cache(language);
CREATE INDEX idx_trend_expires ON yt_studio_trend_cache(expires_at);

-- =====================================================
-- SHORTS FROM LONG TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS yt_studio_shorts_extraction (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_run_id VARCHAR(255) REFERENCES yt_studio_videos(run_id) ON DELETE CASCADE,
    short_run_id VARCHAR(255) REFERENCES yt_studio_videos(run_id) ON DELETE SET NULL,

    source_video_url TEXT NOT NULL,
    start_timestamp DECIMAL(10,2),
    end_timestamp DECIMAL(10,2),

    -- Extraction info
    extraction_reason TEXT,
    viral_score INTEGER,
    suggested_hook TEXT,

    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- VOICE PRESETS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS yt_studio_voice_presets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    provider VARCHAR(100) NOT NULL,
    voice_id VARCHAR(255) NOT NULL,
    language VARCHAR(10) NOT NULL,
    gender VARCHAR(20),
    metadata JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_voice_presets_language ON yt_studio_voice_presets(language);
CREATE INDEX idx_voice_presets_active ON yt_studio_voice_presets(is_active);

-- =====================================================
-- PROMPTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS yt_studio_prompts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prompt_key VARCHAR(100) NOT NULL UNIQUE,
    template TEXT NOT NULL,
    variables TEXT[],
    version INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_prompts_key ON yt_studio_prompts(prompt_key);
CREATE INDEX idx_prompts_active ON yt_studio_prompts(is_active);

-- =====================================================
-- WORKFLOW STATUS VIEW
-- =====================================================
CREATE OR REPLACE VIEW yt_studio_workflow_status AS
SELECT 
    v.run_id,
    v.mode,
    v.video_type,
    v.category,
    v.status,
    v.current_workflow,
    v.error_message,
    v.created_at,
    v.updated_at,
    v.completed_at,
    v.youtube_video_id,
    (SELECT COUNT(*) FROM yt_studio_assets a WHERE a.run_id = v.run_id) as asset_count
FROM yt_studio_videos v;

-- =====================================================
-- DASHBOARD VIEW
-- =====================================================
CREATE OR REPLACE VIEW yt_studio_dashboard AS
SELECT 
    COUNT(*) as total_videos,
    COUNT(*) FILTER (WHERE status = 'completed') as completed_videos,
    COUNT(*) FILTER (WHERE status = 'failed') as failed_videos,
    COUNT(*) FILTER (WHERE status = 'pending') as pending_videos,
    COUNT(*) FILTER (WHERE youtube_video_id IS NOT NULL) as published,
    AVG(estimated_cpm) as avg_cpm,
    SUM(views) as total_views,
    SUM(estimated_revenue) as total_revenue
FROM yt_studio_videos;
