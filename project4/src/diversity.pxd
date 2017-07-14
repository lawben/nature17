cimport numpy as np

cdef packed struct Student:
    np.int16_t id_  # We don't want to carry along the string hash
    np.int8_t sex
    np.int8_t discipline
    np.int8_t nationality