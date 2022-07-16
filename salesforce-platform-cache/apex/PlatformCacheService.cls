public with sharing class PlatformCacheService {
    // fullCacheName - NAMESPACE_PREFIX.PARTITION_NAME.YOUR_KEY
    // partitionName - NAMESPACE_PREFIX.PARTITION_NAM
    // cacheKey - YOUR_KEY

    //Org

    public static void putToOrgCache(String fullCacheName, Object value) {
        Cache.Org.put(fullCacheName, value);
    }

    public static Object getOrgCache(String fullCacheName) {
        return Cache.Org.get(fullCacheName);
    }

    public static void putToOrgByPartitionClass(String partitionName, String cacheKey, Object value) {
        Cache.OrgPartition orgPartition = Cache.Org.getPartition(partitionName);
        orgPartition.put(cacheKey, value);
    }

    public static Object getOrgByPartitionClass(String partitionName, String cacheKey) {
        Cache.OrgPartition orgPartition = Cache.Org.getPartition(partitionName);
        return orgPartition.get(cacheKey);
    }

    //Session

    public static void putToSessionCache(String fullCacheName, Object value) {
        Cache.Session.put(fullCacheName, value);
    }

    public static Object getSessionCache(String fullCacheName) {
        return Cache.Session.get(fullCacheName);
    }

    public static void putToSessionByPartitionClass(String partitionName, String cacheKey, Object value) {
        Cache.SessionPartition orgPartition = Cache.Session.getPartition(partitionName);
        orgPartition.put(cacheKey, value);
    }

    public static Object getSessionByPartitionClass(String partitionName, String cacheKey) {
        Cache.SessionPartition orgPartition = Cache.Session.getPartition(partitionName);
        return orgPartition.get(cacheKey);
    }

    // Use Case

    public static String orgCacheExample() {
        String namespace = 'local';
        String partitionName = 'partitionName';
        String key = 'cacheKey';
        String value = 'valueToCache';

        String fullCacheName = namespace + partitionName + key;

        String myCachedValue = (String) Cache.Org.get(fullCacheName);

        if (myCachedValue == null) {
            Cache.Org.put(fullCacheName, value);
            myCachedValue = value;
        }

        return myCachedValue;
    }

    public static String sessionCacheExample() {
        String namespace = 'local';
        String partitionName = 'partitionName';
        String key = 'cacheKey';
        String value = 'valueToCache';

        String fullCacheName = namespace + partitionName + key;

        String myCachedValue = (String) Cache.Session.get(fullCacheName);

        if (myCachedValue == null) {
            Cache.Session.put(fullCacheName, value);
            myCachedValue = value;
        }

        return myCachedValue;
    }
}
