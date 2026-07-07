在Config目录下面创建一个`SecurityConfig`类，用来做一些关于Spring Security的基础配置

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    /**
     * 密码编码器
     * 仅用于加密，不用于Spring Security的认证
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * 核心安全过滤链配置
     * 使用Lambda表达式进行函数式配置，这是6.x推荐风格
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                // 1. 关闭所有默认的Web UI和认证方式
                .formLogin(AbstractHttpConfigurer::disable) // 关闭默认表单登录页
                .httpBasic(AbstractHttpConfigurer::disable) // 关闭HTTP Basic认证（即那个弹窗）
                .logout(AbstractHttpConfigurer::disable)  // 关闭默认注销端点
                .rememberMe(AbstractHttpConfigurer::disable) // 关闭“记住我”功能

                // 2. 关闭CSRF（因为是API项目，使用无状态JWT）
                .csrf(AbstractHttpConfigurer::disable)

                // 3. 设置为无状态会话（STATELESS），使用JWT
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )

                // 4. 配置请求授权规则
                .authorizeHttpRequests(authorize -> authorize
                        // 公开接口（无需认证）
                        .requestMatchers(
                                "/api/user/register",  // 注册接口
                                "/api/user/login" // 登录接口
                        ).permitAll()
                        // 其他所有请求需要认证（等JWT过滤器加上后就生效）
                        .anyRequest().authenticated()
                );
        return http.build();
    }
}
```

