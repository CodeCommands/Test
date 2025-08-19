# Learning Platform - Product Requirements Document

## 1. Project Overview

### 1.1 Project Summary

A comprehensive learning platform inspired by NetworkChuck Academy, featuring video courses and blog content with a two-tier access system. Anonymous users can preview content, while registered users get full access to all educational materials for free.

### 1.2 Vision Statement

To create a secure, scalable, and user-friendly learning platform that delivers high-quality educational content for free to registered users, while maintaining a clean, professional interface similar to NetworkChuck Academy.

### 1.3 Success Metrics

- User registration and engagement rates
- Content consumption metrics
- User retention rates
- Platform performance and uptime
- Security incident rate (target: 0)

## 2. User Personas & Stories

### 2.1 Primary Personas

**Anonymous Visitor**

- Discovers content through search engines or referrals
- Wants to preview content quality before registering
- Needs clear value proposition for registration

**Registered Member**

- Interested in learning and professional development
- Willing to create an account for full access to content
- Expects access to all platform features and content

### 2.2 User Stories

**As an anonymous visitor:**

- I want to see preview tiles of available content
- I want to understand what content is available
- I want to easily sign up for an account
- I want to see the benefits of registration

**As a registered member:**

- I want full access to all videos and blog content
- I want to track my learning progress
- I want to download resources and materials
- I want to receive notifications about new content
- I want personalized content recommendations

## 3. Functional Requirements

### 3.1 Authentication & Authorization

**User Registration**

- Email/password registration via Supabase Auth
- Email verification required
- Social OAuth options (Google, GitHub) via Supabase Auth
- Password strength validation
- GDPR-compliant data collection
- Automatic user role assignment (default: ‘user’)

**User Authentication**

- Supabase Auth with built-in JWT tokens
- Secure login with rate limiting
- Session management via Supabase
- Password reset functionality via Supabase Auth
- Multi-factor authentication (Supabase Pro feature)

**Authorization Levels (Supabase Roles)**

- `anon`: Anonymous users (preview access only)
- `authenticated`: Registered users (full content access)
- `admin`: Admin users (content management access)
- Custom RLS policies based on user roles

### 3.2 Content Management

**Content Types**

- Video courses with chapters/lessons (Any video platform URLs)
- Blog posts with rich text formatting
- Downloadable resources (PDFs, cheat sheets)
- Interactive elements (quizzes, exercises)

**Content Organization**

- Hierarchical course structure
- Category and tag-based organization
- Search and filtering capabilities
- Content progression tracking

**Content Delivery**

- Video embedded player (iframe) for any video platform
- Content access control for registered users only
- CDN integration for static assets and thumbnails
- Simple URL-based video embedding

### 3.3 User Interface Requirements

**Design System**

- Consistent color scheme matching NetworkChuck Academy
- Responsive design for all device types
- Accessibility compliance (WCAG 2.1 AA)
- Dark/light theme options

**Navigation & Layout**

- Intuitive course catalog browsing
- Progress tracking visualization
- User dashboard with personalized content
- Mobile-first responsive design

### 3.4 User Management

**User Profiles**

- Personal dashboard with progress tracking
- Learning history and bookmarks
- Notification preferences
- Account settings and preferences

**Community Features** (Future Enhancement)

- User comments and discussions
- Content rating and reviews
- User-generated content sharing
- Learning groups and collaboration

## 4. Technical Requirements

### 4.1 Technology Stack

**Frontend**

- Next.js 14+ with App Router
- TypeScript for type safety
- Tailwind CSS for styling
- Framer Motion for animations
- React Hook Form for form handling

**Backend & Database**

- Supabase Auth for user authentication and management
- Supabase Database (PostgreSQL) with Row Level Security
- Supabase Edge Functions for serverless API logic
- Supabase Real-time for live features
- Custom database functions for role management

**Hosting & Infrastructure**

- Vercel for frontend deployment
- Supabase for backend services
- CDN for static assets (images, documents)
- Third-party video platforms for video hosting and delivery
- Environment-based deployments (dev/staging/prod)

### 4.2 Database Schema

**Core Tables**

```sql
-- Supabase Auth Users table (built-in)
-- auth.users is automatically created by Supabase

-- Extended user profiles (leveraging Supabase Auth)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  user_role TEXT DEFAULT 'user' CHECK (user_role IN ('user', 'admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Function to automatically create profile on user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = user_id AND user_role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Course categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Courses
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  thumbnail_url TEXT,
  category_id UUID REFERENCES categories(id),
  preview_enabled BOOLEAN DEFAULT true,
  is_published BOOLEAN DEFAULT false,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Course lessons/videos
CREATE TABLE lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  slug TEXT NOT NULL,
  description TEXT,
  video_url TEXT, -- Any video URL (YouTube, Vimeo, etc.)
  duration INTEGER, -- in seconds (manually entered)
  order_index INTEGER,
  is_preview BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT false,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Blog posts
CREATE TABLE blog_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  content JSONB, -- Rich text content
  excerpt TEXT,
  featured_image_url TEXT,
  is_preview BOOLEAN DEFAULT true,
  is_published BOOLEAN DEFAULT false,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User progress tracking
CREATE TABLE user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
  completed BOOLEAN DEFAULT false,
  progress_percentage REAL DEFAULT 0,
  last_watched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, lesson_id)
);

-- User bookmarks
CREATE TABLE bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);
```

### 4.3 Security Implementation

**Row Level Security (RLS) Policies**

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can view/edit own profile, admins can view all
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id OR is_admin(auth.uid()));

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can manage all profiles" ON profiles
  FOR ALL USING (is_admin(auth.uid()));

-- Categories: Public read, admin write
CREATE POLICY "Categories are publicly readable" ON categories
  FOR SELECT USING (true);

CREATE POLICY "Only admins can manage categories" ON categories
  FOR ALL USING (is_admin(auth.uid()));

-- Courses: Public read for published, admin full access
CREATE POLICY "Published courses are publicly readable" ON courses
  FOR SELECT USING (is_published = true OR is_admin(auth.uid()));

CREATE POLICY "Only admins can manage courses" ON courses
  FOR INSERT WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Only admins can update courses" ON courses
  FOR UPDATE USING (is_admin(auth.uid()));

CREATE POLICY "Only admins can delete courses" ON courses
  FOR DELETE USING (is_admin(auth.uid()));

-- Lessons: Access control based on authentication + admin override
CREATE POLICY "Lesson access control" ON lessons
  FOR SELECT USING (
    (is_published = true AND (
      auth.uid() IS NOT NULL OR -- Authenticated users get full access
      is_preview = true -- Anonymous users get preview lessons only
    )) OR is_admin(auth.uid()) -- Admins get full access
  );

CREATE POLICY "Only admins can manage lessons" ON lessons
  FOR ALL USING (is_admin(auth.uid()));

-- Blog posts: Access control based on authentication + admin override
CREATE POLICY "Blog post access control" ON blog_posts
  FOR SELECT USING (
    (is_published = true AND (
      auth.uid() IS NOT NULL OR -- Authenticated users get full access
      is_preview = true -- Anonymous users get preview only
    )) OR is_admin(auth.uid()) -- Admins get full access
  );

CREATE POLICY "Only admins can manage blog posts" ON blog_posts
  FOR ALL USING (is_admin(auth.uid()));

-- User progress: Users can only manage their own progress
CREATE POLICY "Users can manage own progress" ON user_progress
  FOR ALL USING (auth.uid() = user_id OR is_admin(auth.uid()));

-- Bookmarks: Users can only manage their own bookmarks
CREATE POLICY "Users can manage own bookmarks" ON bookmarks
  FOR ALL USING (auth.uid() = user_id OR is_admin(auth.uid()));

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
```

**API Security**

- Input validation and sanitization
- Rate limiting on all endpoints
- CORS configuration
- SQL injection prevention
- XSS protection headers

### 4.4 Video Embedding System

**Video URL Support**

- YouTube videos (youtube.com, youtu.be)
- Vimeo videos (vimeo.com)
- Other embed-friendly video platforms
- URL validation and format checking
- Automatic video ID extraction for supported platforms

**Video Embedding Implementation**

- Responsive iframe embedding
- Platform detection (YouTube vs Vimeo vs others)
- Fallback handling for unsupported URLs
- Mobile-optimized player experience
- Custom player controls overlay (optional)

**Content Management**

- Simple URL input field for video content
- Manual duration entry (optional)
- Video title and description fields
- Thumbnail URL input (optional)
- Preview functionality in admin dashboard

**Security Considerations**

- URL validation and sanitization
- Content Security Policy (CSP) configuration
- Iframe sandbox restrictions
- Prevention of malicious URL injection
- Whitelist of allowed video domains

### 4.5 Performance Requirements

**Page Load Times**

- Initial page load: < 3 seconds
- Subsequent navigation: < 1 second
- Video embed load time: < 2 seconds

**Scalability**

- Support for 10,000+ concurrent users
- Horizontal scaling capability
- Database query optimization
- CDN implementation for static assets

## 5. Admin Dashboard & Content Management

### 5.1 Admin Access Control

**Admin Role Assignment**

```sql
-- Make user an admin (run manually for initial admin setup)
UPDATE profiles 
SET user_role = 'admin' 
WHERE email = 'your-admin-email@example.com';
```

**Admin Dashboard Access**

- Protected route: `/admin/*`
- Middleware authentication check
- Role-based access verification
- Automatic redirect for non-admin users
- Session-based admin state management

**Admin Authentication Flow**

```typescript
// Example middleware check
export async function adminMiddleware() {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return redirect('/login');
  
  const { data: profile } = await supabase
    .from('profiles')
    .select('user_role')
    .eq('id', user.id)
    .single();
    
  if (profile?.user_role !== 'admin') {
    return redirect('/unauthorized');
  }
}
```

### 5.2 Content Management Interface

**Admin Dashboard Layout**

- Sidebar navigation with content sections
- Real-time content statistics
- Quick action buttons for common tasks
- Recent activity feed
- User engagement metrics

**Course Management**

- Create new courses with metadata
- Video URL input and validation
- Manual video information entry (title, duration)
- Course structure organization (drag-and-drop)
- Bulk lesson operations
- Publishing workflow controls

**Blog Management**

- Rich text editor with preview mode
- SEO metadata management
- Featured image upload
- Category assignment
- Publish/draft status control
- Content scheduling (future enhancement)

**User Management**

- User list with search and filtering
- User activity monitoring
- Role assignment (promote to admin)
- Account status management
- Engagement analytics per user

### 5.3 Initial Admin Setup

**Setting Up Your Admin Account**

1. Register your account through normal signup flow
1. Access Supabase dashboard SQL editor
1. Run admin assignment query:

```sql
UPDATE profiles 
SET user_role = 'admin' 
WHERE email = 'your-email@example.com';
```

1. Clear browser cache and re-login
1. Access admin dashboard at `/admin`

**Supabase Configuration Requirements**

- Email confirmation enabled
- Row Level Security enabled on all tables
- Admin role functions deployed
- Proper CORS settings for your domain
- API keys configured in environment variables

**Environment Variables**

```env
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
NEXT_PUBLIC_SITE_URL=your-site-url
```

### 5.4 Content Workflow

**Publishing Process**

1. Content creation in draft mode
1. Internal review and approval
1. SEO optimization
1. Publication scheduling
1. Performance monitoring

**Version Control**

- Content versioning system
- Rollback capabilities
- Change tracking and audit logs

## 6. Security Best Practices

### 6.1 Data Protection

**Encryption**

- Data encryption at rest and in transit
- Secure API communication (HTTPS only)
- Environment variable protection
- Secure session management

**Privacy Compliance**

- GDPR compliance implementation
- Data retention policies
- User consent management
- Right to deletion support

### 6.2 Application Security

**Authentication Security**

- Strong password requirements
- Account lockout policies
- Session timeout configuration
- Secure password reset flow

**API Security**

- Input validation and sanitization
- SQL injection prevention
- Rate limiting implementation
- API key rotation policies

**Admin Security**

- Role-based access control using Supabase RLS
- Admin session monitoring and timeout
- Audit logging for admin actions
- Secure admin route protection
- Admin activity tracking and notifications

**Content Protection**

- Video content access control for registered users
- Download restrictions for anonymous users
- Admin-only content management operations
- Secure API endpoints with role verification
- Content validation and sanitization

## 7. Development Phases

### 7.1 Phase 1: Foundation (Weeks 1-4)

- Project setup and repository configuration
- Supabase database setup with RLS policies
- Basic authentication implementation
- Core UI components and design system
- Basic course catalog with preview functionality

### 7.2 Phase 2: Core Features & Admin Dashboard (Weeks 5-8)

- Admin dashboard layout and navigation
- Content management interfaces (courses, lessons, blogs)
- Video URL integration and validation
- User dashboard and profile management
- Basic analytics and user management
- Role-based access control implementation

### 7.3 Phase 3: Public Features & Advanced Functionality (Weeks 9-12)

- Public video player implementation with embedded videos
- Blog post system with rich content
- Search and filtering functionality
- Progress tracking system
- User bookmarks and favorites
- Content recommendations
- Mobile app optimization

### 7.4 Phase 4: Enhancement (Weeks 13-16)

- Performance optimization
- Advanced analytics implementation
- SEO optimization
- Security audit and penetration testing
- Launch preparation and testing

## 8. Quality Assurance

### 8.1 Testing Strategy

**Automated Testing**

- Unit tests for all utility functions
- Integration tests for API endpoints
- End-to-end testing for critical user flows
- Performance testing for scalability

**Manual Testing**

- User acceptance testing
- Security testing and vulnerability assessment
- Cross-browser and device testing
- Accessibility compliance verification

### 8.2 Performance Benchmarks

**Response Times**

- API response time: < 200ms
- Database query time: < 100ms
- Video embed load time: < 2 seconds
- Page load time: < 3 seconds

## 9. Registration Strategy

### 9.1 Value Proposition for Registration

**Free Access Benefits**

- Complete access to all video courses and tutorials
- Full blog post content and resources
- Personal progress tracking and learning history
- Bookmarking and favorites functionality
- Email notifications for new content
- Downloadable resources and materials

### 9.2 Registration Incentives

**Preview Limitations for Anonymous Users**

- Video access blocked with registration prompt overlay
- Blog posts show only excerpt/introduction
- No progress tracking or bookmarking
- No access to downloadable resources
- Limited search functionality

**Registration Call-to-Action Strategy**

- Clear value proposition on landing page
- Strategic placement of registration prompts
- Social proof and testimonials
- Video overlay prompts for anonymous users
- Progress indicators showing what they’re missing

### 9.3 User Onboarding

**Welcome Flow**

- Email verification process
- Profile setup and preferences
- Guided tour of platform features
- Recommended content based on interests
- Introduction to progress tracking features

**Engagement Retention**

- Welcome email series
- Weekly content digest emails
- Learning streak notifications
- Achievement badges and milestones
- Personalized content recommendations

## 10. Video Implementation Details

### 10.1 Video Access Control

**Anonymous User Experience**

- Display video thumbnail or placeholder
- Show video title, description, and duration
- Overlay registration prompt when attempting to play
- “Sign up to watch” call-to-action button
- Course preview with lesson count and total duration

**Registered User Experience**

- Full video embedding with player controls
- Progress tracking using browser localStorage
- Resume playback from last position (if supported by platform)
- Autoplay next lesson functionality (optional)
- Video speed control and quality selection (platform dependent)

### 10.2 Technical Implementation

**Video URL Processing**

```javascript
// Example URL processing functions
function extractVideoId(url) {
  if (url.includes('youtube.com') || url.includes('youtu.be')) {
    return extractYouTubeId(url);
  } else if (url.includes('vimeo.com')) {
    return extractVimeoId(url);
  }
  return null;
}

function generateEmbedUrl(url) {
  const videoId = extractVideoId(url);
  if (url.includes('youtube.com') || url.includes('youtu.be')) {
    return `https://www.youtube.com/embed/${videoId}`;
  } else if (url.includes('vimeo.com')) {
    return `https://player.vimeo.com/video/${videoId}`;
  }
  return url; // Return original URL as fallback
}
```

**Progress Tracking System**

- Track video watch time using browser events
- Store progress in local storage and database
- Resume functionality from last watched position
- Completion badges and achievements
- Learning streak tracking

**Content Security Policy**

```
Content-Security-Policy: 
  frame-src 'self' https://www.youtube.com https://youtube.com https://player.vimeo.com;
  script-src 'self' https://www.youtube.com https://player.vimeo.com;
```

## 11. SEO and Content Discovery

### 11.1 SEO Strategy

**Technical SEO**

- Server-side rendering for public pages
- Structured data markup for courses and blogs
- XML sitemaps for content discovery
- Meta tags and Open Graph optimization
- Mobile-first indexing optimization

**Content SEO**

- Keyword-optimized course and blog titles
- Rich descriptions and meta content
- Internal linking strategy
- Content tagging and categorization
- Regular content freshness updates

### 11.2 Social Sharing

**Social Media Integration**

- Open Graph tags for rich social previews
- Twitter Cards for enhanced sharing
- Easy social sharing buttons
- Course completion sharing features
- User-generated content opportunities

## 12. Analytics and Monitoring

### 12.1 User Analytics

**Engagement Metrics**

- Registration conversion rates
- Content completion rates
- Time spent on platform
- Return visitor patterns
- Most popular content identification

**User Journey Analysis**

- Registration funnel analysis
- Content discovery patterns
- Drop-off point identification
- Feature usage analytics
- User feedback collection

### 12.2 Technical Monitoring

**Performance Monitoring**

- Real-time performance metrics
- Error tracking and alerting
- Database performance monitoring
- CDN performance analytics
- Uptime monitoring and alerting

**Security Monitoring**

- Failed login attempt tracking
- Suspicious activity detection
- API rate limit monitoring
- Data access audit logs
- Security incident response procedures

## 13. Admin Dashboard Features

### 13.1 Dashboard Overview

- **Statistics Cards**: Total users, courses, lessons, blog posts
- **Recent Activity**: Latest user registrations, content views, completions
- **Quick Actions**: Create course, add lesson, publish blog post
- **Analytics Summary**: Top performing content, user engagement trends

### 13.2 Content Management Features

**Course Creation Workflow**

1. Basic course information (title, description, category)
1. Thumbnail upload or URL input
1. Lesson structure planning
1. Video URL addition per lesson
1. Preview and publishing controls

**Video Integration Tools**

- URL validation and format checking
- Video platform detection (YouTube, Vimeo, etc.)
- Manual metadata entry (title, duration, description)
- Embed preview functionality
- Bulk video URL processing for multiple lessons

**Blog Management Tools**

- WYSIWYG rich text editor
- Markdown support for technical content
- Image upload and management
- SEO optimization tools (meta tags, descriptions)
- Content preview before publishing

### 13.3 User Management Dashboard

- **User List**: Searchable and filterable user directory
- **User Profiles**: Individual user progress and activity
- **Role Management**: Promote users to admin status
- **Analytics**: User engagement, popular content, completion rates
- **Communication**: Send announcements or notifications

### 13.4 Admin Dashboard Security

- Two-factor authentication for admin accounts (future)
- Admin action audit logs
- IP restriction for admin access (future)
- Session timeout for admin users
- Secure password requirements for admin accounts