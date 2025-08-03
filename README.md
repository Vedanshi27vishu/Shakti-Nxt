# **Shakti: Empowering Innovation and Business Growth**

![Cover](docs/Cover.png)

Shakti is an innovative business and community platform that empowers entrepreneurs, innovators, and business enthusiasts to connect, collaborate, and grow.  
By combining **social networking**, **business guidance**, and **financial tools**, Shakti serves as a **one-stop platform** for idea sharing, business networking, and entrepreneurial success.  

---

## **Introduction**

Starting and scaling a business is challenging. Entrepreneurs often struggle to find the right **community, mentorship, and resources** to bring their ideas to life.  
**Shakti bridges this gap** by providing a **social-media-like experience** tailored for businesses, where users can:  

- **Share ideas and achievements**  
- **Connect with like-minded innovators**  
- **Collaborate on projects**  
- **Access business tools and insights**  

Whether you are a **budding entrepreneur** or an **established business owner**, Shakti fuels your journey from **concept to success**.  

---

## **Key Features**

### **1. 3-Step Smart Signup**
- Seamless **multi-step onboarding** capturing:
  1. **Personal Details** (name, email, profile)
  2. **Business Details** (idea/concept, industry)
  3. **Financial Details** (basic revenue/finance info)  
- **Google Sign-In Integration**: Authenticate first, save user data only after full signup.

---

### **2. Avatar Screen**
- **AI Advisor** to guide your business journey  
- **Expert Videos** for learning and growth  
- **Business Documents** to read and implement strategies  
- **Interactive Flowcharts** to improve business profitability  
- **Your Progress Tracker** to monitor growth  
- **Budget Overview & Feedback Section** to refine strategies  

---

### **3. Finance Screen**
- **Monthly Revenue** overview  
- **Customer Count & Insights**  
- **Daily Task Manager** with:
  - **Today’s Tasks**
  - **Completed Tasks**
  - **Pending Tasks**  
- Helps you **organize operations and monitor performance**  

---

### **4. Invest Screen**
- **Total Outstanding Loans**  
- **Monthly Loan Payments** overview  
- **Active Investment & Investment Amounts**  
- **Government & Private Schemes** suggestions  
- **Invest in Groups** for collaboration  
- **Financial Tracker** to monitor payments and returns  

---

### **5. Community Screen**
- **Business-Oriented Post Feed** to see all posts related to your interests  
- **Create & Share Posts** with your network  
- **Followers & Following** section to manage your community  
- **Integrated Chat** to collaborate directly with other entrepreneurs  

---

### **6. Secure & Scalable Backend**
- **Node.js + Express + MongoDB** backend  
- **JWT-based authentication** for secure access  
- **Socket.IO for Real-Time Messaging**  
- **Modular APIs** for:
  - Community & Posts  
  - Chat & Messaging  
  - Finance & Investments  
  - Business Recommendations (PDF & Web-Scraping)  


---

## **Shakti App Workflow Overview**

![Flow](docs/flow.png)  

1. **Sign up / Google Authentication**  
2. **Complete 3-Step Profile Setup**  
3. **Access Community Feed**  
4. **Post, Like, Comment, and Follow**  
5. **Chat & Collaborate in Real-Time**  
6. **Explore Business Tools and Insights**  

---


## **Screenshots**

<img width="1305" height="665" alt="Screenshot 2025-08-03 231920" src="https://github.com/user-attachments/assets/a0ad303d-aca7-41bc-bd91-061802a6a467" />
<img width="1273" height="633" alt="Screenshot 2025-08-03 231945" src="https://github.com/user-attachments/assets/48377dc0-96e0-486d-ae5c-d0db7d1bde67" />
<img width="1295" height="631" alt="Screenshot 2025-08-03 230539" src="https://github.com/user-attachments/assets/846d0381-1a24-4729-8f7c-f83533b6c27e" />

---


## Getting Started


To get started with Shakti, follow these steps:

1. **Installation**: Clone the repository to your local machine.
2. **Setup Environment**: Install the required dependencies using `npm install` and ensure MongoDB is running locally or use MongoDB Atlas.
3. **Configuration**: Configure the backend by creating a `.env` file in the project root with the following variables:
   - `MONGO_URI` = your MongoDB connection string
   - `JWT_SECRET` = secret key for JWT authentication
   - `GOOGLE_CLIENT_ID` = Google OAuth client ID
   - `PORT` = port for backend server (default 5000)
4. **Run the Application**: Start the Shakti backend server with `npm start` and verify that everything is running smoothly.
5. **Frontend Connection**: If using the Flutter frontend, update the base API URL to point to your backend server.
6. **Test APIs**: Use Postman or any API client to test the endpoints like:
   - `/api/auth` for authentication
   - `/api/signup` for 3-step signup
   - `/api/posts` for community posts
   - `/api/messages` for real-time chat

**Note:** Make sure to use strong JWT secrets and a reliable MongoDB connection (Atlas recommended) for production deployment.



## Contributing

We welcome contributions from the community to improve Shakti-Nxt. To contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/improvement`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to the branch (`git push origin feature/improvement`).
6. Create a new Pull Request.


## Contact

For inquiries or assistance, please contact:

- **Vedanshi Aggarwal** - [GitHub Profile](https://github.com/Vedanshi27vishu)
- **Aikansh Tiwari** - [GitHub Profile](https://github.com/aikansh008)


