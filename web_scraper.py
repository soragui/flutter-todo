#!/usr/bin/env python3
"""
Web Scraper - 网页内容爬取工具
使用 requests 和 BeautifulSoup 抓取网页内容
"""

import argparse
import json
import sys
import time
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup


# 默认 User-Agent 列表
DEFAULT_USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
]


def get_random_user_agent():
    """随机选择一个 User-Agent"""
    import random
    return random.choice(DEFAULT_USER_AGENTS)


def fetch_page(url, delay=1, timeout=30, custom_headers=None):
    """
    抓取网页内容
    
    Args:
        url: 目标 URL
        delay: 请求前延迟（秒）
        timeout: 请求超时时间（秒）
        custom_headers: 自定义请求头
    
    Returns:
        Response 对象或 None
    """
    # 添加延迟，避免请求过快
    if delay > 0:
        time.sleep(delay)
    
    # 设置请求头
    headers = {
        "User-Agent": get_random_user_agent(),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
        "Accept-Encoding": "gzip, deflate, br",
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1",
    }
    
    # 合并自定义请求头
    if custom_headers:
        headers.update(custom_headers)
    
    try:
        response = requests.get(url, headers=headers, timeout=timeout, allow_redirects=True)
        response.raise_for_status()  # 检查 HTTP 错误
        
        # 尝试自动检测编码
        response.encoding = response.apparent_encoding
        
        return response
    
    except requests.exceptions.Timeout:
        print(f"错误: 请求超时 ({timeout}秒)", file=sys.stderr)
        return None
    except requests.exceptions.ConnectionError:
        print("错误: 网络连接失败，请检查网络或 URL 是否正确", file=sys.stderr)
        return None
    except requests.exceptions.HTTPError as e:
        print(f"错误: HTTP 错误 - {e}", file=sys.stderr)
        return None
    except requests.exceptions.RequestException as e:
        print(f"错误: 请求失败 - {e}", file=sys.stderr)
        return None


def parse_html(html, base_url):
    """
    解析 HTML 内容，提取标题、段落和链接
    
    Args:
        html: HTML 文本
        base_url: 基础 URL（用于处理相对链接）
    
    Returns:
        包含提取数据的字典
    """
    soup = BeautifulSoup(html, 'html.parser')
    
    # 提取标题
    title = ""
    if soup.title:
        title = soup.title.string.strip() if soup.title.string else ""
    elif soup.find('h1'):
        title = soup.find('h1').get_text(strip=True)
    
    # 提取所有段落文本
    paragraphs = []
    for p in soup.find_all('p'):
        text = p.get_text(strip=True)
        if text:  # 只保留非空段落
            paragraphs.append(text)
    
    # 提取所有链接
    links = []
    seen_urls = set()
    for a in soup.find_all('a', href=True):
        href = a['href'].strip()
        if not href or href.startswith('#') or href.startswith('javascript:'):
            continue
        
        # 转换为绝对 URL
        absolute_url = urljoin(base_url, href)
        
        # 去重
        if absolute_url in seen_urls:
            continue
        seen_urls.add(absolute_url)
        
        link_text = a.get_text(strip=True)
        links.append({
            "url": absolute_url,
            "text": link_text if link_text else "(无文本)"
        })
    
    return {
        "title": title,
        "paragraphs": paragraphs,
        "links": links,
        "paragraph_count": len(paragraphs),
        "link_count": len(links)
    }


def output_text(data, url):
    """以文本格式输出结果"""
    print(f"=" * 60)
    print(f"URL: {url}")
    print(f"=" * 60)
    print(f"\n【标题】")
    print(data['title'] if data['title'] else "(无标题)")
    
    print(f"\n【段落文本】({data['paragraph_count']} 个段落)")
    print("-" * 60)
    for i, paragraph in enumerate(data['paragraphs'], 1):
        print(f"{i}. {paragraph}\n")
    
    print(f"\n【链接】({data['link_count']} 个链接)")
    print("-" * 60)
    for i, link in enumerate(data['links'], 1):
        print(f"{i}. {link['text']}")
        print(f"   URL: {link['url']}\n")


def output_json(data, url):
    """以 JSON 格式输出结果"""
    result = {
        "url": url,
        "title": data['title'],
        "paragraphs": data['paragraphs'],
        "links": data['links'],
        "stats": {
            "paragraph_count": data['paragraph_count'],
            "link_count": data['link_count']
        }
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))


def main():
    parser = argparse.ArgumentParser(
        description="网页内容爬取工具 - 提取页面标题、段落和链接",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  python web_scraper.py -u https://example.com
  python web_scraper.py -u https://example.com -f json
  python web_scraper.py -u https://example.com -d 2 -o output.json
        """
    )
    
    parser.add_argument(
        '-u', '--url',
        required=True,
        help='要抓取的网页 URL'
    )
    
    parser.add_argument(
        '-f', '--format',
        choices=['text', 'json'],
        default='text',
        help='输出格式: text 或 json (默认: text)'
    )
    
    parser.add_argument(
        '-d', '--delay',
        type=float,
        default=1.0,
        help='请求前延迟时间（秒），默认为 1 秒'
    )
    
    parser.add_argument(
        '-t', '--timeout',
        type=int,
        default=30,
        help='请求超时时间（秒），默认为 30 秒'
    )
    
    parser.add_argument(
        '-o', '--output',
        help='输出文件路径（如果不指定则输出到控制台）'
    )
    
    parser.add_argument(
        '--user-agent',
        help='自定义 User-Agent 字符串'
    )
    
    args = parser.parse_args()
    
    # 验证 URL
    parsed = urlparse(args.url)
    if not parsed.scheme or not parsed.netloc:
        print(f"错误: 无效的 URL - {args.url}", file=sys.stderr)
        sys.exit(1)
    
    # 设置自定义 User-Agent
    custom_headers = {}
    if args.user_agent:
        custom_headers['User-Agent'] = args.user_agent
    
    # 抓取网页
    print(f"正在抓取: {args.url}", file=sys.stderr)
    response = fetch_page(args.url, delay=args.delay, timeout=args.timeout, custom_headers=custom_headers)
    
    if response is None:
        sys.exit(1)
    
    print(f"成功获取页面 (状态码: {response.status_code})", file=sys.stderr)
    
    # 解析 HTML
    data = parse_html(response.text, args.url)
    
    # 重定向输出到文件（如果指定）
    if args.output:
        try:
            with open(args.output, 'w', encoding='utf-8') as f:
                if args.format == 'json':
                    result = {
                        "url": args.url,
                        "title": data['title'],
                        "paragraphs": data['paragraphs'],
                        "links": data['links'],
                        "stats": {
                            "paragraph_count": data['paragraph_count'],
                            "link_count": data['link_count']
                        }
                    }
                    json.dump(result, f, ensure_ascii=False, indent=2)
                else:
                    f.write(f"URL: {args.url}\n")
                    f.write(f"标题: {data['title']}\n\n")
                    f.write(f"段落文本 ({data['paragraph_count']} 个):\n")
                    f.write("-" * 60 + "\n")
                    for i, paragraph in enumerate(data['paragraphs'], 1):
                        f.write(f"{i}. {paragraph}\n\n")
                    f.write(f"\n链接 ({data['link_count']} 个):\n")
                    f.write("-" * 60 + "\n")
                    for i, link in enumerate(data['links'], 1):
                        f.write(f"{i}. {link['text']}\n")
                        f.write(f"   URL: {link['url']}\n\n")
            print(f"结果已保存到: {args.output}", file=sys.stderr)
        except IOError as e:
            print(f"错误: 无法写入文件 - {e}", file=sys.stderr)
            sys.exit(1)
    else:
        # 输出到控制台
        if args.format == 'json':
            output_json(data, args.url)
        else:
            output_text(data, args.url)


if __name__ == '__main__':
    main()
