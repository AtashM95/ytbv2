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
    scope VARCHAR(50) NOT NULL DEFAULT 'global',
    environment VARCHAR(50) NOT NULL DEFAULT 'production',
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_by VARCHAR(100),
    
    CONSTRAINT yt_config_unique UNIQUE (key, scope, environment)
);

CREATE INDEX idx_config_env ON yt_studio_config(environment);
CREATE INDEX idx_config_scope ON yt_studio_config(scope);
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
    language VARCHAR(10) NOT NULL,
    gender VARCHAR(20) NOT NULL,
    voice_id VARCHAR(255) NOT NULL,
    voice_name VARCHAR(255),
    provider VARCHAR(50) DEFAULT 'elevenlabs',
    stability DECIMAL(3,2) DEFAULT 0.5,
    similarity_boost DECIMAL(3,2) DEFAULT 0.75,
    style DECIMAL(3,2) DEFAULT 0.0,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT voice_preset_unique UNIQUE (language, gender, is_default)
);

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_yt_config_updated_at
    BEFORE UPDATE ON yt_studio_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_yt_videos_updated_at
    BEFORE UPDATE ON yt_studio_videos
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- DEFAULT DATA
-- =====================================================

-- Default voice presets
INSERT INTO yt_studio_voice_presets (language, gender, voice_id, voice_name, is_default) VALUES
    ('en', 'male', 'pNInz6obpgDQGcFmaJgB', 'Adam', true),
    ('en', 'female', 'EXAVITQu4vr4xnSDxMaL', 'Bella', true),
    ('ar', 'male', '2EiwWnXFnvU5JabPnv8n', 'Clyde', true),
    ('ar', 'female', 'XB0fDUnXU5powFXDhCwa', 'Charlotte', true),
    ('tr', 'male', 'ErXwobaYiN019PkySvjV', 'Antoni', true),
    ('tr', 'female', 'MF3mGyEYCl7XYWbV9V6O', 'Elli', true),
    ('es', 'male', 'VR6AewLTigWG4xSOukaG', 'Arnold', true),
    ('es', 'female', 'jBpfuIE2acCO8z3wKNLl', 'Gigi', true),
    ('fr', 'male', 'yoZ06aMxZJJ28mfd3POQ', 'Sam', true),
    ('fr', 'female', 'XrExE9yKIg1WjnnlVkGX', 'Lily', true),
    ('de', 'male', 'ODq5zmih8GrVes37Dizd', 'Patrick', true),
    ('de', 'female', 'jsCqWAovK2LkecY7zXl4', 'Freya', true),
    ('pt', 'male', 'g5CIjZEefAph4nQFvHAz', 'Ethan', true),
    ('pt', 'female', 'oWAxZDx7w5VEj9dCyTzz', 'Grace', true),
    ('hi', 'male', 'nPczCjzI2devNBz1zQrb', 'Brian', true),
    ('hi', 'female', 'piTKgcLEGmPE4e6mEKli', 'Nicole', true)
ON CONFLICT DO NOTHING;

-- Default configuration
INSERT INTO yt_studio_config (key, value, value_type, scope, environment, notes) VALUES
    -- OpenAI settings
    ('openai.model', 'gpt-4o-mini', 'string', 'global', 'production', 'Default model for script generation'),
    ('openai.model', 'gpt-4o-mini', 'string', 'global', 'test', 'Test mode model'),
    ('openai.max_tokens', '4000', 'number', 'global', 'production', 'Max tokens for script'),
    ('openai.temperature', '0.7', 'number', 'global', 'production', 'Creativity level'),
    
    -- TTS settings
    ('tts.provider', 'elevenlabs', 'string', 'global', 'production', 'TTS provider'),
    ('tts.model', 'eleven_multilingual_v2', 'string', 'global', 'production', 'ElevenLabs model'),
    
    -- Render settings
    ('render.endpoint', 'https://api.shotstack.io/stage', 'string', 'global', 'test', 'Shotstack sandbox'),
    ('render.endpoint', 'https://api.shotstack.io/v1', 'string', 'global', 'production', 'Shotstack production'),
    ('render.default_fps', '30', 'number', 'global', 'production', 'Default FPS'),
    
    -- Publish settings
    ('publish.enabled', 'false', 'boolean', 'global', 'test', 'Disable publish in test'),
    ('publish.enabled', 'true', 'boolean', 'global', 'production', 'Enable publish in production'),
    ('publish.default_privacy', 'unlisted', 'string', 'global', 'production', 'Default privacy'),
    
    -- Video length presets (in seconds)
    ('video.length.short_3_5', '240', 'number', 'global', 'production', '3-5 min = 240 sec avg'),
    ('video.length.medium_8_12', '600', 'number', 'global', 'production', '8-12 min = 600 sec avg'),
    ('video.length.long_15_20', '1050', 'number', 'global', 'production', '15-20 min = 1050 sec avg'),
    ('video.length.extra_25_40', '1950', 'number', 'global', 'production', '25-40 min = 1950 sec avg'),
    ('video.length.test', '30', 'number', 'global', 'test', 'Test mode = 30 sec'),
    
    -- Short video presets
    ('short.length.15s', '15', 'number', 'global', 'production', '15 second short'),
    ('short.length.30s', '30', 'number', 'global', 'production', '30 second short'),
    ('short.length.60s', '60', 'number', 'global', 'production', '60 second short'),
    
    -- Best publish times (JSON)
    ('publish.best_times', '{"US": {"weekday": "14:00-16:00 EST", "weekend": "10:00-12:00 EST"}, "UK": {"weekday": "17:00-19:00 GMT"}, "Global": {"best": "Tuesday/Thursday 14:00-16:00 EST"}}', 'json', 'global', 'production', 'Best publish times by region')
ON CONFLICT DO NOTHING;

-- =====================================================
-- VIEWS
-- =====================================================

-- Active videos view
CREATE OR REPLACE VIEW v_active_videos AS
SELECT 
    v.*,
    (SELECT COUNT(*) FROM yt_studio_assets a WHERE a.run_id = v.run_id) as asset_count
FROM yt_studio_videos v
WHERE v.status NOT IN ('deleted', 'archived')
ORDER BY v.created_at DESC;

-- Video statistics view
CREATE OR REPLACE VIEW v_video_stats AS
SELECT 
    DATE_TRUNC('day', created_at) as date,
    mode,
    video_type,
    category,
    COUNT(*) as total_videos,
    COUNT(*) FILTER (WHERE status = 'completed') as completed,
    COUNT(*) FILTER (WHERE status = 'failed') as failed,
    COUNT(*) FILTER (WHERE youtube_video_id IS NOT NULL) as published,
    SUM(views) as total_views,
    SUM(estimated_revenue) as total_revenue
FROM yt_studio_videos
GROUP BY DATE_TRUNC('day', created_at), mode, video_type, category
ORDER BY date DESC;

-- =====================================================
-- GRANTS (adjust as needed)
-- =====================================================
-- GRANT ALL ON ALL TABLES IN SCHEMA public TO your_user;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO your_user;

