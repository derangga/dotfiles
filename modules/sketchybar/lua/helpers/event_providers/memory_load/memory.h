#include <mach/mach.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/sysctl.h>

struct memory {
    mach_port_t host;
    vm_size_t page_size;
    int used_percent;
};

static inline void memory_init(struct memory* mem) {
    mem->host = mach_host_self();
    mem->page_size = vm_page_size;
    mem->used_percent = 0;
}

static inline void memory_update(struct memory* mem) {
    vm_statistics64_data_t stats;
    mach_msg_type_number_t count = sizeof(stats) / sizeof(integer_t);
    
    kern_return_t error = host_statistics64(mem->host,
                                            HOST_VM_INFO64,
                                            (host_info_t)&stats,
                                            &count);
    
    if (error != KERN_SUCCESS) {
        printf("Error: Could not read memory statistics.\n");
        return;
    }
    
    uint64_t total_mem = 0;
    size_t len = sizeof(total_mem);
    sysctlbyname("hw.memsize", &total_mem, &len, NULL, 0);
    
    uint64_t used_mem = (uint64_t)(stats.wire_count + stats.internal_page_count + stats.compressor_page_count) * mem->page_size;
    
    mem->used_percent = (int)((double)used_mem / (double)total_mem * 100.0);
    
    if (mem->used_percent < 0) mem->used_percent = 0;
    if (mem->used_percent > 100) mem->used_percent = 100;
}