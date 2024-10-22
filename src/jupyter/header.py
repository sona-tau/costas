
def load_file(file_path: str):
    """
    Opens a file given by file_path and returns its content as a Python object.
    This will evaluate the contents of a file so make sure you know what that
    file has and that it won't exceed thhe recursion limit defined by Python.

    Parameters
    ----------
    file_path : str
        The file path to the file that should be opened and evaluated.

    Returns
    -------
    a : The evaluation of the file's contents.
    """
    f = open(file_path, "r")
    content = eval(f.read())
    f.close()
    return content

def save_variable(file_path: str, var):
    """
    Saves a variable to a file. Will overwrite the file's contents if it already
    exists.

    Parameters
    ----------
    file_path : str
        The file path to the file you want to write to.

    var : a
        Any variable you want to save.
    """
    f = open(file_path, "w")
    f.write(repr(var))
    f.close()

class lazy_load_ct:
    """
    Same functionality as load_file(file_path), in this case the object returned
    is lazily evaluated as to not load the entire file at once into the project.
    """
    def __init__(self, file_path: str):
        """
        Constructor for lazy_load_ct. An example invocation could be
        `lazy_load_ct("path/to/my_cts.txt")`.

        Parameters
        ----------
        file_path : str
            The path to the file you want to open.

        Returns
        -------
        <lazy_load_ct object> : A Python object containing the file's data, not
        yet evaluated.
        """
        self.file_path = file_path

    def __iter__(self):
        """
        File iterator. This will evaluate the contents of the file and return an
        iterator to each element.

        Returns
        -------
        <generator object lazy_load_ct.__iter__> : An iterator to the contents
        of the file.
        """
        for struct in load_file(self.file_path):
            yield struct


class lazy_load_ct_fragmented:
    """
    Same functionality as lazy_load_ct(file_path), in this case the file that
    should be read can be fragmented into several files which are all read and
    evaluated when needed. Can greatly reduce the memory footprint of evaluating
    large datasets.     """
    def __init__(self, ctilde: str, data_dir: str, fragment_count: int):
        """
        Constructor for lazy_load_ct_fragmented. An example invocation could
        look like `lazy_load_ct_fragmented("cts_7", "data/clean", 5)`.

        Parameters
        ----------
        ctilde : str
            The ctilde to read.

        data_dir : str
            The path to the data directory in which all the files are located.

        fragment_count : int
            The amount of fragments
        """
        self.ctilde = ctilde
        self.data_dir = data_dir
        self.fragment_count = fragment_count

    def __iter__(self):
        """
        File iterator. This will evaluate the contents of one file at a time and
        return an iterator to each element. Every time a new file is loaded, the
        garbage collector is expected to safely collect the contents of the
        previous file, leaving the memory footprint the same.

        Returns
        -------
        <generator object lazy_load_ct_fragmented.__iter__> : An iterator to an
        element in the file.
        """
        for i in range(1, self.fragment_count + 1):
            for struct in load_file(self.data_dir + f"/frag_{i}_{self.ctilde}.txt"):
                yield struct
