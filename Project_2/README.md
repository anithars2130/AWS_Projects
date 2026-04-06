# 🌐 Static Website Hosting on AWS (S3 + CloudFront)

---

## 📌 Project Overview

This project demonstrates hosting a **static website on AWS** using **Amazon S3** and **CloudFront** with secure HTTPS access.  

The goal of this project is to build a **low-cost, highly available, and globally accessible website** without using any servers.

---

## 🚀 Architecture

**User → CloudFront → S3 Bucket**  

- **Amazon S3** stores the website files  
- **CloudFront** delivers content globally with low latency  
- HTTPS is enabled using CloudFront default certificate

---

## 🧱 Resources Used

- **S3 Bucket Name:** `ani-static-website-197`  
- **Region:** `us-east-1`  
- **CloudFront Distribution:** `ANI-Static-Site`  
- **CloudFront URL:** `https://d2iz4xijy4o0i5.cloudfront.net`

---

## ⚙️ Step-by-Step Implementation

### ✅ Step 1: Created Website Files
Created two files locally:

**index.html**
- Main landing page  
- Displays welcome message

**error.html**
- Custom error page

---

### ✅ Step 2: Created S3 Bucket
- Bucket Name: `ani-static-website-197`  
- Disabled **Block Public Access**  
- Kept all other settings as default

---

### ✅ Step 3: Uploaded Website Files
- Uploaded:
  - `index.html`  
  - `error.html`  
- Verified files are available in S3 bucket

---

### ✅ Step 4: Enabled Static Website Hosting
- Enabled static hosting in S3  
- Configured:
  - Index document → `index.html`  
  - Error document → `error.html`  
- Received S3 Website Endpoint (HTTP)

---

### ✅ Step 5: Configured Bucket Policy
Added public read access policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::ani-static-website-197/*"
    }
  ]
}


### ✅ Step 6: Created CloudFront Distribution

- **Origin:** S3 Bucket (`ani-static-website-197`)  
- **Viewer Protocol Policy:** Redirect HTTP to HTTPS  
- **Default Root Object:** `index.html`  
- **Enabled secure access via HTTPS**

---

## 🌍 Output

### 🔹 S3 Website URL (HTTP)
- Used for testing

### 🔹 CloudFront URL (HTTPS)
[https://d2iz4xijy4o0i5.cloudfront.net](https://d2iz4xijy4o0i5.cloudfront.net)

---

## 🖼️ Screenshots

### S3 Buckets
![S3 Bucket List](./Screenshots/s3_bucket_list.png)

### S3 Bucket Policy
![S3 Bucket Policy](./Screenshots/s3_bucket_policy.png)

### S3 Objects
![S3 Object List](./Screenshots/s3_bucket_object_list.png)

### S3 Static Web Hosting
![S3 Static Web Hosting](./Screenshots/s3_static_web_hosting.png)

### CloudFront Distribution
![CF Distribution List](./Screenshots/CloudFront_distribution_list.png)

### CloudFront Distribution Settings
![CF Distribution Settings](./Screenshots/CloudFront_distribution_settings.png)


✔️ Website loads securely using HTTPS  
✔️ Faster global delivery via CDN

---

## 💡 Key Learnings

- Hosting static websites using S3  
- Managing public access using bucket policies  
- Using CloudFront as CDN  
- Enabling HTTPS without custom domain  
- Understanding origin and caching behavior

---

## 🧹 Cleanup

To avoid charges:

1. Delete CloudFront Distribution  
2. Empty S3 bucket  
3. Delete S3 bucket


Prepared By	:	Anitha RS
Date		:	06-04-2026