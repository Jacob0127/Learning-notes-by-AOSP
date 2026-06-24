```sql
-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS smart_ai DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE smart_ai;

-- 2. 用户表（修正版）
CREATE TABLE users (
                       id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
                       username VARCHAR(128) NOT NULL COMMENT '用户名',
                       password VARCHAR(128) NOT NULL COMMENT '密码',
                       phone VARCHAR(20) UNIQUE COMMENT '手机号',  -- 改为UNIQUE，可空
                       email VARCHAR(100) UNIQUE COMMENT '邮箱',
                       user_type ENUM('new', 'regular', 'vip', 'root', 'admin') DEFAULT 'new' COMMENT '用户身份',
                       status ENUM('active', 'inactive') DEFAULT 'active' COMMENT '账号状态',
                       avatar_url VARCHAR(500) COMMENT '头像URL',
                       last_login_time DATETIME COMMENT '最后登录时间',
                       created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                       updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                       INDEX idx_username (username),
                       INDEX idx_phone (phone),
                       INDEX idx_email (email)
) COMMENT='用户表';

-- 3. 分类表
CREATE TABLE categories (
                            id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
                            name VARCHAR(128) NOT NULL COMMENT '分类名称',
                            parent_id BIGINT COMMENT '父分类ID',  -- 改为BIGINT保持一致
                            level INT DEFAULT 1 COMMENT '分类层级',
                            sort_order INT DEFAULT 0 COMMENT '排序',
                            description VARCHAR(500) COMMENT '分类描述',
                            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                            INDEX idx_parent_id (parent_id),
                            INDEX idx_level (level)
) COMMENT='知识分类表';

-- 4. 知识库表
CREATE TABLE knowledge_base (
                                id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '知识ID',
                                question TEXT NOT NULL COMMENT '问题',
                                answer TEXT NOT NULL COMMENT '答案',
                                category_id BIGINT COMMENT '分类ID',  -- 改为BIGINT
                                tags VARCHAR(200) COMMENT '标签',
                                view_count INT DEFAULT 0 COMMENT '查看次数',
                                helpful_count INT DEFAULT 0 COMMENT '有帮助次数',
                                unhelpful_count INT DEFAULT 0 COMMENT '无帮助次数',  -- 新增
                                is_hot BOOLEAN DEFAULT FALSE COMMENT '是否热门',
                                created_by BIGINT COMMENT '创建人',
                                review_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending' COMMENT '审核状态',
                                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                INDEX idx_category_id (category_id),
                                INDEX idx_is_hot (is_hot),
                                INDEX idx_review_status (review_status),
                                FULLTEXT idx_question (question) WITH PARSER ngram
) COMMENT='知识库表';

-- 5. 对话会话表
CREATE TABLE conversations (
                               id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会话ID',
                               session_id VARCHAR(64) UNIQUE NOT NULL COMMENT '会话唯一标识',
                               user_id BIGINT COMMENT '用户ID',
                               title VARCHAR(200) COMMENT '对话标题（AI自动生成）',
                               status ENUM('active', 'closed', 'transferred') DEFAULT 'active' COMMENT '会话状态',
                               transfer_to_agent BOOLEAN DEFAULT FALSE COMMENT '是否转人工',
                               agent_id BIGINT COMMENT '处理客服ID',
                               message_count INT DEFAULT 0 COMMENT '消息数量',
                               ai_message_count INT DEFAULT 0 COMMENT 'AI消息数量',
                               satisfaction_score INT COMMENT '满意度评分(1-5)',
                               start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
                               end_time DATETIME,
                               last_message_time DATETIME COMMENT '最后消息时间',
                               INDEX idx_user_id (user_id),
                               INDEX idx_session_id (session_id),
                               INDEX idx_status (status),
                               INDEX idx_start_time (start_time)
) COMMENT='对话会话表';

-- 6. 消息表（MySQL版本）
CREATE TABLE messages (
                          id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '消息ID',
                          session_id VARCHAR(64) NOT NULL COMMENT '会话ID',  -- 重要！方便直接查询
                          conversation_id BIGINT NOT NULL COMMENT '会话表ID',
                          message_type ENUM('user', 'ai', 'agent') NOT NULL COMMENT '消息类型',
                          content TEXT NOT NULL COMMENT '消息内容',
                          user_id BIGINT COMMENT '发送用户ID',  -- 新增
                          ai_model VARCHAR(50) COMMENT '使用的AI模型',
                          ai_tokens INT COMMENT '消耗的token数量',
                          referenced_knowledge_id BIGINT COMMENT '引用的知识ID',
                          is_helpful TINYINT(1) COMMENT '是否有帮助：1是，0否，NULL未评价',
                          metadata JSON COMMENT '扩展信息，如：{"user_ip":"192.168.1.1"}',  -- 新增
                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                          INDEX idx_session_id (session_id),
                          INDEX idx_conversation_id (conversation_id),
                          INDEX idx_user_id (user_id),
                          INDEX idx_message_type (message_type),
                          INDEX idx_created_at (created_at)
) COMMENT='消息表';
```

