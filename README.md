# Azure User Module

A web application for managing user authentication and device control through Azure Functions and SQL Server.

## Purpose

This project provides a secure user authentication system and device control interface. It allows users to:
- Log in securely with username/password
- View and control devices
- Register new devices
- Monitor device states and statuses

## Tech Stack

- **Frontend**: HTML, CSS, JavaScript
- **Backend**: Azure Functions
- **Database**: Azure SQL Server
- **Authentication**: Custom session-based authentication with SHA-256 password hashing
- **Deployment**: Azure Static Web Apps with GitHub Actions

## Database Structure

### Users Table
- `Username` (varchar): Unique identifier for the user
- `PasswordHash` (varchar): SHA-256 hashed password
- `CreatedAt` (datetime): User account creation timestamp

### Devices Table
- `DeviceID` (varchar): Unique identifier for the device
- `DeviceType` (varchar): Type of device (e.g., "N1000")
- `Location` (varchar): Physical location of the device
- `PortID` (varchar): Port identifier for the device
- `MacAddress` (varchar): MAC address of the device
- `Status` (varchar): Current status of the device
- `LastUpdated` (datetime): Last status update timestamp

### DeviceStates Table
- `StateID` (int): Unique identifier for the state
- `StateName` (varchar): Name of the state
- `Description` (varchar): Description of the state

### DeviceStatus Table
- `DeviceID` (varchar): Reference to Devices table
- `StateID` (int): Reference to DeviceStates table
- `UpdatedAt` (datetime): Status update timestamp

## API Endpoints

### Authentication
- `userLogin`: Authenticates users and returns a session token
  - Method: POST
  - Parameters: username, passwordHash

### Device Management
- `getDevices`: Retrieves all devices and their current states
  - Method: GET
  - Parameters: sessionToken
- `setDevice`: Updates a device's state
  - Method: POST
  - Parameters: deviceId, stateId, sessionToken
- `registerDevice`: Registers a new device
  - Method: POST
  - Parameters: deviceId, deviceType, macAddress, session, username, location, portId

## Build and Deployment

### Prerequisites
- Azure CLI
- Azure Functions Core Tools
- SQL Server Management Studio (for database management)

### Local Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/AzureUserModule.git
   cd AzureUserModule
   ```

2. Set up environment variables:
   Create a `.env` file in the root directory with the following variables:
   ```
   USER_FUNCTION_DB_USER=your_db_user
   USER_FUNCTION_DB_PASSWORD=your_db_password
   USER_FUNCTION_DB_SERVER=your_db_server
   USER_FUNCTION_DEVICE_DB_NAME=your_db_name
   ```

### Deployment

The project uses GitHub Actions for automated deployment to Azure Static Web Apps. The workflow:
1. Builds the client application
2. Generates configuration files
3. Deploys to Azure Static Web Apps

Required GitHub Secrets:
- `AZURE_FUNCTION_URL`: URL of the Azure Function app
- `AZURE_FUNCTION_KEY`: Access key for the Azure Function app
- `SET_DEVICE_URL`: URL for the setDevice function
- `SET_DEVICE_KEY`: Access key for the setDevice function
- `AZURE_STATIC_WEB_APPS_API_TOKEN_POLITE_SAND_0C33DEF00`: Token for Azure Static Web Apps deployment

## Security Features

- Password hashing using SHA-256
- Session-based authentication with time-based validation
- SQL injection prevention through parameterized queries
- Input validation and sanitization
- Secure environment variable management

## Planned Development and Improvements

### Security Enhancements
1. Implement proper CORS policies
2. Add rate limiting to prevent brute force attacks
3. Implement proper session management with expiration
4. Add input validation for all API parameters
5. Implement proper error handling and logging
6. Add request validation middleware
7. Implement proper password policies
8. Add API versioning
9. Implement proper audit logging

### Database Improvements
1. Add database indexes for frequently queried columns
2. Implement database views for common queries
3. Add database constraints for data integrity
4. Implement proper database backup strategy
5. Add database monitoring and alerting

### Application Improvements
1. Add unit tests and integration tests
2. Implement proper logging system
3. Add user management features
4. Implement device grouping functionality
5. Add bulk device operations
6. Implement device status history
7. Add user activity logging
8. Implement proper error handling and user feedback
9. Add input validation on the client side
10. Implement proper session timeout handling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
