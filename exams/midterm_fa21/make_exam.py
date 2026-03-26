from ybe import read_ybe_file, YbeToLatex, YbeToMarkdown

ybe_exam = read_ybe_file('./midterm.ybe')
YbeToLatex().convert(ybe_exam, './midterm.tex', copy_resources=False)
