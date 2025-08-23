# Operations Guide - Spatial Mempool VisionOS

## Overview

This guide covers deployment and operational aspects of the Spatial Mempool VisionOS app, including both public API usage and self-hosted backend configurations.

## Deployment Options

### Option 1: Public mempool.space API (Recommended for most users)

The simplest deployment uses the public mempool.space API with no local backend required.

#### VisionOS App Configuration
```swift
// In MempoolService.swift
private let baseURL = "https://mempool.space/api/v1"
```

#### Advantages
- ✅ No infrastructure setup required
- ✅ Always up-to-date with latest Bitcoin data
- ✅ High availability and performance
- ✅ No maintenance overhead

#### Limitations
- ❌ Dependent on external service
- ❌ No privacy guarantees
- ❌ Rate limiting may apply
- ❌ No custom configuration options

### Option 2: Self-Hosted Backend

For users who want full control, privacy, or custom configurations.

#### Prerequisites
- Bitcoin Core node (fully synced)
- Docker and Docker Compose
- 4GB+ RAM recommended
- 50GB+ storage for database

#### Quick Start
```bash
# Clone the repository
git clone https://github.com/jeffmarcilliat/mempool.git
cd mempool/backend

# Copy and configure environment
cp .env.example .env
# Edit .env with your Bitcoin node settings

# Start the backend
docker-compose up -d

# Verify services are running
docker-compose ps
```

#### Configuration Files

**Environment Variables (.env)**
```bash
# Bitcoin node connection
BITCOIN_RPC_HOST=127.0.0.1
BITCOIN_RPC_PORT=8332
BITCOIN_RPC_USER=your_username
BITCOIN_RPC_PASSWORD=your_password

# Network selection
NETWORK=mainnet  # or testnet, signet, regtest

# Service ports
BACKEND_PORT=8999
FRONTEND_PORT=8080

# Optional Tor proxy
TOR_ENABLED=true
TOR_HOST=127.0.0.1
TOR_PORT=9050
```

**VisionOS App Configuration**
```swift
// Update MempoolService.swift for self-hosted backend
private let baseURL = "http://your-server:8999/api/v1"
// or for Tor: "http://your-onion-address.onion:8999/api/v1"
```

## Bitcoin Node Distributions

### Umbrel Integration

Spatial Mempool can integrate with Umbrel Bitcoin nodes:

```bash
# Umbrel app store installation (future)
# For now, manual setup:

# SSH into Umbrel
ssh umbrel@umbrel.local

# Navigate to app directory
cd ~/umbrel/app-data

# Clone and configure mempool
git clone https://github.com/jeffmarcilliat/mempool.git spatial-mempool
cd spatial-mempool/backend

# Configure for Umbrel
cp .env.example .env
# Edit .env:
# BITCOIN_RPC_HOST=10.21.21.8
# BITCOIN_RPC_PORT=8332
# BITCOIN_RPC_USER=umbrel
# BITCOIN_RPC_PASSWORD=<from umbrel bitcoin config>

# Start services
docker-compose up -d
```

### Start9 Embassy Integration

For Start9 Embassy nodes:

```bash
# SSH into Embassy
ssh start9@embassy.local

# Install as custom service
mkdir -p /embassy-data/package-data/spatial-mempool
cd /embassy-data/package-data/spatial-mempool

# Clone and configure
git clone https://github.com/jeffmarcilliat/mempool.git .
cd backend

# Configure for Embassy
cp .env.example .env
# Edit .env with Embassy Bitcoin service settings

# Start services
docker-compose up -d
```

### RaspiBlitz Integration

For RaspiBlitz nodes:

```bash
# SSH into RaspiBlitz
ssh admin@raspiblitz.local

# Install in apps directory
cd /mnt/hdd/app-data
sudo mkdir spatial-mempool
cd spatial-mempool

# Clone and configure
sudo git clone https://github.com/jeffmarcilliat/mempool.git .
cd backend

# Configure for RaspiBlitz
sudo cp .env.example .env
# Edit .env with RaspiBlitz Bitcoin settings

# Start services
sudo docker-compose up -d
```

## Tor Configuration

### Enabling Tor Proxy

For enhanced privacy, configure Tor proxy:

```bash
# In .env file
TOR_ENABLED=true
TOR_HOST=127.0.0.1
TOR_PORT=9050

# Start with Tor profile
docker-compose --profile tor up -d
```

### Tor Hidden Service

To expose your backend as a Tor hidden service:

```bash
# Add to torrc
echo "HiddenServiceDir /var/lib/tor/mempool/" >> /etc/tor/torrc
echo "HiddenServicePort 8999 127.0.0.1:8999" >> /etc/tor/torrc

# Restart Tor
sudo systemctl restart tor

# Get your onion address
sudo cat /var/lib/tor/mempool/hostname
```

### VisionOS App Tor Configuration

```swift
// Configure app to use Tor proxy
private let baseURL = "http://your-onion-address.onion:8999/api/v1"

// Or configure SOCKS proxy in URLSession
let config = URLSessionConfiguration.default
config.connectionProxyDictionary = [
    kCFNetworkProxiesSOCKSProxy: "127.0.0.1",
    kCFNetworkProxiesSOCKSPort: 9050
]
```

## Monitoring and Maintenance

### Health Checks

Monitor your backend services:

```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f mempool-backend

# Check API health
curl http://localhost:8999/api/v1/blocks

# Database status
docker-compose exec mempool-db mysql -u mempool -p -e "SHOW TABLES;"
```

### Performance Monitoring

Key metrics to monitor:

- **API Response Time**: Should be <500ms for most endpoints
- **Database Size**: Grows ~1GB per month on mainnet
- **Memory Usage**: Backend typically uses 1-2GB RAM
- **Disk I/O**: High during initial sync, moderate during operation

### Backup and Recovery

```bash
# Backup database
docker-compose exec mempool-db mysqldump -u mempool -p mempool > backup.sql

# Backup cache data
docker run --rm -v mempool_mempool-cache:/data -v $(pwd):/backup alpine tar czf /backup/cache-backup.tar.gz -C /data .

# Restore database
docker-compose exec -T mempool-db mysql -u mempool -p mempool < backup.sql
```

## Troubleshooting

### Common Issues

#### Backend Won't Start
```bash
# Check Bitcoin node connectivity
docker-compose exec mempool-backend curl http://$BITCOIN_RPC_HOST:$BITCOIN_RPC_PORT

# Check database connectivity
docker-compose exec mempool-backend nc -zv mempool-db 3306

# View detailed logs
docker-compose logs mempool-backend
```

#### VisionOS App Can't Connect
```bash
# Test API endpoint
curl http://your-backend:8999/api/v1/blocks

# Check firewall rules
sudo ufw status

# Verify network connectivity
ping your-backend-host
```

#### Performance Issues
```bash
# Check resource usage
docker stats

# Optimize database
docker-compose exec mempool-db mysql -u mempool -p -e "OPTIMIZE TABLE blocks, transactions;"

# Clear cache if needed
docker-compose exec mempool-backend rm -rf /backend/cache/*
```

### Log Analysis

Important log patterns to watch:

```bash
# Successful block processing
grep "Block.*processed" logs/

# API errors
grep "ERROR" logs/ | grep -v "404"

# Database connection issues
grep "database" logs/ | grep -i error

# Memory warnings
grep -i "memory\|oom" logs/
```

## Security Considerations

### Network Security
- Use HTTPS/TLS for all API communications
- Configure firewall rules to limit access
- Consider VPN access for remote connections
- Enable Tor for enhanced privacy

### Authentication
- Use strong RPC passwords for Bitcoin node
- Rotate database passwords regularly
- Limit API access to trusted networks
- Consider API key authentication for production

### Data Privacy
- Self-hosted backends provide full data privacy
- No transaction data leaves your infrastructure
- Consider encrypted storage for sensitive data
- Regular security updates for all components

## Scaling and Performance

### Horizontal Scaling
```bash
# Multiple backend instances
docker-compose up --scale mempool-backend=3

# Load balancer configuration
# (nginx/haproxy configuration examples)
```

### Vertical Scaling
- Increase database memory allocation
- Add SSD storage for better I/O performance
- Optimize Bitcoin node configuration
- Tune database parameters for workload

## Integration with VisionOS App

### Configuration Management
The VisionOS app should support multiple backend configurations:

```swift
enum BackendConfiguration {
    case publicAPI
    case selfHosted(url: String)
    case tor(onionAddress: String)
}
```

### Connection Testing
Implement health checks in the app:

```swift
func testBackendConnection() async -> Bool {
    // Test API connectivity
    // Verify data freshness
    // Check WebSocket availability
}
```

### Fallback Strategy
Implement graceful fallback:

1. Try self-hosted backend first
2. Fall back to public API if self-hosted unavailable
3. Cache data for offline functionality
4. Notify user of connection status

---

**Last Updated**: August 23, 2025  
**Version**: 1.0  
**Maintainer**: Development Team
